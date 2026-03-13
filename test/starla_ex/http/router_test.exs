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
end
