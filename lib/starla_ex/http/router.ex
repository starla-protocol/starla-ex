defmodule StarlaEx.HTTP.Router do
  use Plug.Router

  alias StarlaEx.HTTP.Response
  alias StarlaEx.Store

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  get "/" do
    Response.json(conn, 200, %{
      implementation: "starla-ex",
      state: "early_implementation",
      target_protocol_version: "v1",
      target_binding: "HTTP Binding v1",
      target_profile: "Core"
    })
  end

  get "/v1/agent-definitions" do
    Response.json(conn, 200, Store.list_agent_definitions())
  end

  get "/v1/agent-definitions/:agent_definition_id" do
    respond(conn, Store.get_agent_definition(agent_definition_id))
  end

  post "/v1/agent-definitions/:agent_definition_id/disable" do
    respond(conn, Store.disable_agent_definition(agent_definition_id))
  end

  post "/v1/agent-definitions/:agent_definition_id/enable" do
    respond(conn, Store.enable_agent_definition(agent_definition_id))
  end

  get "/v1/agent-instances" do
    Response.json(conn, 200, Store.list_agent_instances())
  end

  get "/v1/agent-instances/:agent_instance_id" do
    respond(conn, Store.get_agent_instance(agent_instance_id))
  end

  post "/v1/agent-instances/:agent_instance_id/pause" do
    respond(conn, Store.pause_agent_instance(agent_instance_id))
  end

  post "/v1/agent-instances/:agent_instance_id/resume" do
    respond(conn, Store.resume_agent_instance(agent_instance_id))
  end

  post "/v1/agent-instances/:agent_instance_id/terminate" do
    respond(conn, Store.terminate_agent_instance(agent_instance_id))
  end

  get "/v1/sessions" do
    Response.json(conn, 200, Store.list_sessions())
  end

  get "/v1/sessions/:session_id" do
    respond(conn, Store.get_session(session_id))
  end

  post "/v1/sessions/:session_id/close" do
    respond(conn, Store.close_session(session_id))
  end

  match _ do
    Response.error(conn, :not_found)
  end

  defp respond(conn, {:ok, payload}) do
    Response.json(conn, 200, payload)
  end

  defp respond(conn, {:error, error}) do
    Response.error(conn, error)
  end
end
