defmodule StarlaEx.HTTP.RouterTest do
  use ExUnit.Case, async: false

  import Plug.Conn
  import Plug.Test

  alias StarlaEx.HTTP.Router
  alias StarlaEx.Store

  setup do
    Store.reset!()
    :ok
  end

  test "root exposes current claim target" do
    conn = send_request(:get, "/")

    assert conn.status == 200

    assert decode_body(conn) == %{
             "implementation" => "starla-ex",
             "state" => "early_implementation",
             "target_protocol_version" => "v1",
             "target_binding" => "HTTP Binding v1",
             "target_profile" => "Core"
           }
  end

  test "agent definition routes cover listing inspection disable and enable" do
    conn = send_request(:get, "/v1/agent-definitions")

    assert conn.status == 200

    assert Enum.any?(decode_body(conn), fn item ->
             item["agent_definition_id"] == "agent-def-enabled"
           end)

    conn = send_request(:get, "/v1/agent-definitions/agent-def-enabled")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "enabled"

    conn = send_request(:post, "/v1/agent-definitions/agent-def-enabled/disable")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "disabled"

    conn = send_request(:post, "/v1/agent-definitions/agent-def-enabled/enable")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "enabled"
  end

  test "agent instance routes cover listing inspection pause resume and terminate" do
    conn = send_request(:get, "/v1/agent-instances")

    assert conn.status == 200

    assert Enum.any?(decode_body(conn), fn item ->
             item["agent_instance_id"] == "agent-inst-primary"
           end)

    conn = send_request(:get, "/v1/agent-instances/agent-inst-primary")
    assert conn.status == 200
    assert decode_body(conn)["agent_definition_id"] == "agent-def-enabled"

    conn = send_request(:post, "/v1/agent-instances/agent-inst-primary/pause")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "paused"

    conn = send_request(:post, "/v1/agent-instances/agent-inst-primary/resume")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "ready"

    conn = send_request(:post, "/v1/agent-instances/agent-inst-primary/terminate")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "terminated"
  end

  test "session routes cover listing inspection and close" do
    conn = send_request(:get, "/v1/sessions")

    assert conn.status == 200

    assert Enum.any?(decode_body(conn), fn item ->
             item["session_id"] == "session-open"
           end)

    conn = send_request(:get, "/v1/sessions/session-open")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "open"

    conn = send_request(:post, "/v1/sessions/session-open/close")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "closed"
  end

  test "execution routes cover listing inspection and cancel" do
    conn = send_request(:get, "/v1/executions")

    assert conn.status == 200

    assert Enum.any?(decode_body(conn), fn item ->
             item["execution_id"] == "execution-pending"
           end)

    conn = send_request(:get, "/v1/executions/execution-failed")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "failed"

    conn = send_request(:get, "/v1/executions/execution-pending/context")
    assert conn.status == 200
    assert decode_body(conn)["session_material"]["scope"] == "session-open"

    conn = send_request(:post, "/v1/executions/execution-pending/cancel")
    assert conn.status == 200
    assert decode_body(conn)["state"] == "canceled"
  end

  test "submit work creates pending execution and visible context" do
    conn =
      send_request(:post, "/v1/agent-instances/agent-inst-primary/submit-work", %{
        "input" => %{"task" => "demo"},
        "session_id" => "session-open",
        "references" => [%{"kind" => "note", "id" => "ref-1"}]
      })

    assert conn.status == 201
    body = decode_body(conn)
    assert body["state"] == "pending"
    assert body["session_id"] == "session-open"

    execution_id = body["execution_id"]

    conn = send_request(:get, "/v1/executions/#{execution_id}/context")
    assert conn.status == 200

    context = decode_body(conn)
    assert context["agent_instance_id"] == "agent-inst-primary"
    assert context["session_id"] == "session-open"
    assert context["session_material"]["scope"] == "session-open"
    assert context["explicit_input"]["task"] == "demo"
    assert Enum.at(context["explicit_references"], 0)["id"] == "ref-1"
  end

  test "submit work rejected when instance paused" do
    conn =
      send_request(:post, "/v1/agent-instances/agent-inst-paused/submit-work", %{
        "input" => %{"task" => "blocked"}
      })

    assert conn.status == 409
    assert decode_body(conn) == %{"error" => %{"code" => "invalid_state"}}
  end

  test "execution lifecycle reaches terminal completion in order" do
    conn =
      send_request(:post, "/v1/agent-instances/agent-inst-primary/submit-work", %{
        "input" => %{"task" => "completes"}
      })

    assert conn.status == 201
    execution_id = decode_body(conn)["execution_id"]

    eventually(fn ->
      response = send_request(:get, "/v1/executions/#{execution_id}")
      body = decode_body(response)

      response.status == 200 and body["state"] == "completed" and
        Enum.map(body["recent_events"], & &1["event"]) == [
          "execution.created",
          "execution.state_changed",
          "execution.completed"
        ]
    end)
  end

  test "execution failure remains normal inspection" do
    conn =
      send_request(:post, "/v1/agent-instances/agent-inst-primary/submit-work", %{
        "input" => %{"synthetic_outcome" => "failed"}
      })

    assert conn.status == 201
    execution_id = decode_body(conn)["execution_id"]

    eventually(fn ->
      response = send_request(:get, "/v1/executions/#{execution_id}")
      body = decode_body(response)

      response.status == 200 and body["state"] == "failed" and
        List.last(body["recent_events"])["event"] == "execution.failed"
    end)
  end

  defp send_request(method, path, body \\ nil) do
    conn =
      conn(method, path, body && Jason.encode!(body))
      |> maybe_put_json_content_type(body)

    Router.call(conn, Router.init([]))
  end

  defp maybe_put_json_content_type(conn, nil), do: conn

  defp maybe_put_json_content_type(conn, _body) do
    put_req_header(conn, "content-type", "application/json")
  end

  defp decode_body(conn) do
    Jason.decode!(conn.resp_body)
  end

  defp eventually(fun, attempts \\ 20)

  defp eventually(fun, attempts) when attempts > 0 do
    if fun.() do
      :ok
    else
      Process.sleep(15)
      eventually(fun, attempts - 1)
    end
  end

  defp eventually(_fun, 0) do
    flunk("condition did not become true")
  end
end
