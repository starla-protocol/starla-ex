defmodule StarlaEx.Store do
  use GenServer

  alias StarlaEx.Domain.Agents
  alias StarlaEx.Domain.Agents.AgentDefinition
  alias StarlaEx.Domain.Agents.AgentInstance
  alias StarlaEx.Domain.Sessions
  alias StarlaEx.Domain.Sessions.Session

  defmodule State do
    @enforce_keys [:agent_definitions, :agent_instances, :sessions]
    defstruct [:agent_definitions, :agent_instances, :sessions]

    @type t :: %__MODULE__{
            agent_definitions: %{String.t() => AgentDefinition.t()},
            agent_instances: %{String.t() => AgentInstance.t()},
            sessions: %{String.t() => Session.t()}
          }

    @spec seeded() :: t()
    def seeded do
      %__MODULE__{
        agent_definitions: %{
          "agent-def-enabled" => Agents.new_definition("agent-def-enabled", :enabled),
          "agent-def-disabled" => Agents.new_definition("agent-def-disabled", :disabled)
        },
        agent_instances: %{
          "agent-inst-primary" =>
            Agents.new_instance("agent-inst-primary", "agent-def-enabled", :ready),
          "agent-inst-helper" =>
            Agents.new_instance("agent-inst-helper", "agent-def-enabled", :ready),
          "agent-inst-paused" =>
            Agents.new_instance("agent-inst-paused", "agent-def-enabled", :paused),
          "agent-inst-terminated" =>
            Agents.new_instance("agent-inst-terminated", "agent-def-enabled", :terminated)
        },
        sessions: %{
          "session-open" =>
            Sessions.new_session("session-open", :open, %{"scope" => "session-open"}),
          "session-closed" =>
            Sessions.new_session("session-closed", :closed, %{"scope" => "session-closed"})
        }
      }
    end
  end

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, Keyword.put_new(opts, :name, __MODULE__))
  end

  @spec reset!() :: :ok
  def reset! do
    GenServer.call(__MODULE__, :reset)
  end

  @spec list_agent_definitions() :: [AgentDefinition.t()]
  def list_agent_definitions do
    GenServer.call(__MODULE__, :list_agent_definitions)
  end

  @spec get_agent_definition(String.t()) ::
          {:ok, AgentDefinition.t()} | {:error, :not_found}
  def get_agent_definition(agent_definition_id) do
    GenServer.call(__MODULE__, {:get_agent_definition, agent_definition_id})
  end

  @spec disable_agent_definition(String.t()) ::
          {:ok, AgentDefinition.t()} | {:error, :not_found | :invalid_state}
  def disable_agent_definition(agent_definition_id) do
    GenServer.call(__MODULE__, {:disable_agent_definition, agent_definition_id})
  end

  @spec enable_agent_definition(String.t()) ::
          {:ok, AgentDefinition.t()} | {:error, :not_found | :invalid_state}
  def enable_agent_definition(agent_definition_id) do
    GenServer.call(__MODULE__, {:enable_agent_definition, agent_definition_id})
  end

  @spec list_agent_instances() :: [AgentInstance.t()]
  def list_agent_instances do
    GenServer.call(__MODULE__, :list_agent_instances)
  end

  @spec get_agent_instance(String.t()) ::
          {:ok, AgentInstance.t()} | {:error, :not_found}
  def get_agent_instance(agent_instance_id) do
    GenServer.call(__MODULE__, {:get_agent_instance, agent_instance_id})
  end

  @spec pause_agent_instance(String.t()) ::
          {:ok, AgentInstance.t()} | {:error, :not_found | :invalid_state}
  def pause_agent_instance(agent_instance_id) do
    GenServer.call(__MODULE__, {:pause_agent_instance, agent_instance_id})
  end

  @spec resume_agent_instance(String.t()) ::
          {:ok, AgentInstance.t()} | {:error, :not_found | :invalid_state}
  def resume_agent_instance(agent_instance_id) do
    GenServer.call(__MODULE__, {:resume_agent_instance, agent_instance_id})
  end

  @spec terminate_agent_instance(String.t()) ::
          {:ok, AgentInstance.t()} | {:error, :not_found | :invalid_state}
  def terminate_agent_instance(agent_instance_id) do
    GenServer.call(__MODULE__, {:terminate_agent_instance, agent_instance_id})
  end

  @spec list_sessions() :: [Session.t()]
  def list_sessions do
    GenServer.call(__MODULE__, :list_sessions)
  end

  @spec get_session(String.t()) :: {:ok, Session.t()} | {:error, :not_found}
  def get_session(session_id) do
    GenServer.call(__MODULE__, {:get_session, session_id})
  end

  @spec close_session(String.t()) :: {:ok, Session.t()} | {:error, :not_found | :invalid_state}
  def close_session(session_id) do
    GenServer.call(__MODULE__, {:close_session, session_id})
  end

  @impl true
  def init(:ok) do
    {:ok, State.seeded()}
  end

  @impl true
  def handle_call(:reset, _from, _state) do
    {:reply, :ok, State.seeded()}
  end

  def handle_call(:list_agent_definitions, _from, state) do
    {:reply, sort_by_id(Map.values(state.agent_definitions), & &1.agent_definition_id), state}
  end

  def handle_call({:get_agent_definition, agent_definition_id}, _from, state) do
    {:reply, fetch(state.agent_definitions, agent_definition_id), state}
  end

  def handle_call({:disable_agent_definition, agent_definition_id}, _from, state) do
    {reply, next_state} =
      update_entity(
        state,
        :agent_definitions,
        agent_definition_id,
        &Agents.disable_definition/1
      )

    {:reply, reply, next_state}
  end

  def handle_call({:enable_agent_definition, agent_definition_id}, _from, state) do
    {reply, next_state} =
      update_entity(
        state,
        :agent_definitions,
        agent_definition_id,
        &Agents.enable_definition/1
      )

    {:reply, reply, next_state}
  end

  def handle_call(:list_agent_instances, _from, state) do
    {:reply, sort_by_id(Map.values(state.agent_instances), & &1.agent_instance_id), state}
  end

  def handle_call({:get_agent_instance, agent_instance_id}, _from, state) do
    {:reply, fetch(state.agent_instances, agent_instance_id), state}
  end

  def handle_call({:pause_agent_instance, agent_instance_id}, _from, state) do
    {reply, next_state} =
      update_entity(state, :agent_instances, agent_instance_id, &Agents.pause_instance/1)

    {:reply, reply, next_state}
  end

  def handle_call({:resume_agent_instance, agent_instance_id}, _from, state) do
    {reply, next_state} =
      update_entity(state, :agent_instances, agent_instance_id, &Agents.resume_instance/1)

    {:reply, reply, next_state}
  end

  def handle_call({:terminate_agent_instance, agent_instance_id}, _from, state) do
    {reply, next_state} =
      update_entity(state, :agent_instances, agent_instance_id, &Agents.terminate_instance/1)

    {:reply, reply, next_state}
  end

  def handle_call(:list_sessions, _from, state) do
    {:reply, sort_by_id(Map.values(state.sessions), & &1.session_id), state}
  end

  def handle_call({:get_session, session_id}, _from, state) do
    {:reply, fetch(state.sessions, session_id), state}
  end

  def handle_call({:close_session, session_id}, _from, state) do
    {reply, next_state} = update_entity(state, :sessions, session_id, &Sessions.close_session/1)

    {:reply, reply, next_state}
  end

  defp fetch(collection, id) do
    case Map.fetch(collection, id) do
      {:ok, value} -> {:ok, value}
      :error -> {:error, :not_found}
    end
  end

  defp update_entity(state, field, id, updater) do
    collection = Map.fetch!(state, field)

    case Map.fetch(collection, id) do
      {:ok, value} ->
        case updater.(value) do
          {:ok, updated} ->
            {{:ok, updated}, Map.put(state, field, Map.put(collection, id, updated))}

          {:error, reason} ->
            {{:error, reason}, state}
        end

      :error ->
        {{:error, :not_found}, state}
    end
  end

  defp sort_by_id(items, fun) do
    Enum.sort_by(items, fun)
  end
end
