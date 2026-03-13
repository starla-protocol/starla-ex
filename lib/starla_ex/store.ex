defmodule StarlaEx.Store do
  use GenServer

  alias StarlaEx.Domain.Agents
  alias StarlaEx.Domain.Agents.AgentDefinition
  alias StarlaEx.Domain.Agents.AgentInstance
  alias StarlaEx.Domain.Executions
  alias StarlaEx.Domain.Executions.Execution
  alias StarlaEx.Domain.Sessions
  alias StarlaEx.Domain.Sessions.Session

  defmodule State do
    @enforce_keys [:agent_definitions, :agent_instances, :sessions, :executions, :next_execution]
    defstruct [:agent_definitions, :agent_instances, :sessions, :executions, :next_execution]

    @type t :: %__MODULE__{
            agent_definitions: %{String.t() => AgentDefinition.t()},
            agent_instances: %{String.t() => AgentInstance.t()},
            sessions: %{String.t() => Session.t()},
            executions: %{String.t() => Execution.t()},
            next_execution: pos_integer()
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
        },
        executions: seeded_executions(),
        next_execution: 1
      }
    end

    defp seeded_executions do
      %{
        "execution-failed" =>
          Executions.new_execution(
            "execution-failed",
            "agent-inst-primary",
            :failed,
            nil,
            nil,
            %{"synthetic_outcome" => "failed"},
            [],
            nil,
            nil,
            :fail,
            [
              Executions.event("execution.created", nil),
              Executions.event("execution.state_changed", :running),
              Executions.event("execution.failed", :failed)
            ]
          ),
        "execution-completed" =>
          Executions.new_execution(
            "execution-completed",
            "agent-inst-helper",
            :completed,
            "session-open",
            nil,
            %{"seed" => "completed"},
            [],
            %{"scope" => "session-open"},
            nil,
            :complete,
            [
              Executions.event("execution.created", nil),
              Executions.event("execution.state_changed", :running),
              Executions.event("execution.completed", :completed)
            ]
          ),
        "execution-running" =>
          Executions.new_execution(
            "execution-running",
            "agent-inst-primary",
            :running,
            "session-open",
            nil,
            %{"seed" => "running"},
            [],
            %{"scope" => "session-open"},
            nil,
            :complete,
            [
              Executions.event("execution.created", nil),
              Executions.event("execution.state_changed", :running)
            ]
          ),
        "execution-pending" =>
          Executions.new_execution(
            "execution-pending",
            "agent-inst-helper",
            :pending,
            "session-open",
            nil,
            %{"seed" => "pending"},
            [],
            %{"scope" => "session-open"},
            nil,
            :complete,
            [Executions.event("execution.created", nil)]
          )
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

  @spec list_executions() :: [map()]
  def list_executions do
    GenServer.call(__MODULE__, :list_executions)
  end

  @spec get_execution(String.t()) :: {:ok, map()} | {:error, :not_found}
  def get_execution(execution_id) do
    GenServer.call(__MODULE__, {:get_execution, execution_id})
  end

  @spec get_execution_context(String.t()) ::
          {:ok, Executions.ContextSnapshot.t()} | {:error, :not_found}
  def get_execution_context(execution_id) do
    GenServer.call(__MODULE__, {:get_execution_context, execution_id})
  end

  @spec submit_work(String.t(), map()) :: {:ok, map()} | {:error, :not_found | :invalid_state}
  def submit_work(agent_instance_id, request) do
    GenServer.call(__MODULE__, {:submit_work, agent_instance_id, request})
  end

  @spec mark_execution_running(String.t()) :: :ok | {:error, :not_found | :invalid_state}
  def mark_execution_running(execution_id) do
    GenServer.call(__MODULE__, {:mark_execution_running, execution_id})
  end

  @spec finish_execution(String.t()) :: :ok | {:error, :not_found | :invalid_state}
  def finish_execution(execution_id) do
    GenServer.call(__MODULE__, {:finish_execution, execution_id})
  end

  @spec cancel_execution(String.t()) :: {:ok, map()} | {:error, :not_found | :invalid_state}
  def cancel_execution(execution_id) do
    GenServer.call(__MODULE__, {:cancel_execution, execution_id})
  end

  @spec delegate_execution(String.t(), map()) ::
          {:ok, map()} | {:error, :not_found | :invalid_state}
  def delegate_execution(parent_execution_id, request) do
    GenServer.call(__MODULE__, {:delegate_execution, parent_execution_id, request})
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

  def handle_call(:list_executions, _from, state) do
    executions =
      state.executions
      |> Map.values()
      |> Enum.map(&Executions.list_item/1)
      |> sort_by_id(& &1.execution_id)

    {:reply, executions, state}
  end

  def handle_call({:get_execution, execution_id}, _from, state) do
    case Map.fetch(state.executions, execution_id) do
      {:ok, execution} -> {:reply, {:ok, Executions.snapshot(execution)}, state}
      :error -> {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:get_execution_context, execution_id}, _from, state) do
    case Map.fetch(state.executions, execution_id) do
      {:ok, execution} -> {:reply, {:ok, Executions.context_snapshot(execution)}, state}
      :error -> {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:submit_work, agent_instance_id, request}, _from, state) do
    case Map.fetch(state.agent_instances, agent_instance_id) do
      {:ok, %{state: :ready}} ->
        with {:ok, session_id, session_material} <- resolve_session(state, request) do
          execution_id = "exec-#{state.next_execution}"

          execution =
            Executions.new_execution(
              execution_id,
              agent_instance_id,
              :pending,
              session_id,
              nil,
              Map.fetch!(request, "input"),
              Map.get(request, "references", []),
              session_material,
              nil,
              Executions.synthetic_outcome(Map.fetch!(request, "input")),
              [Executions.event("execution.created", nil)]
            )

          next_state = %{
            state
            | executions: Map.put(state.executions, execution_id, execution),
              next_execution: state.next_execution + 1
          }

          {:reply, {:ok, Executions.submit_work_view(execution)}, next_state}
        else
          {:error, reason} -> {:reply, {:error, reason}, state}
        end

      {:ok, _instance} ->
        {:reply, {:error, :invalid_state}, state}

      :error ->
        {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:mark_execution_running, execution_id}, _from, state) do
    {reply, next_state} =
      update_entity(state, :executions, execution_id, &Executions.mark_running/1)

    {:reply, coerce_runtime_reply(reply), next_state}
  end

  def handle_call({:finish_execution, execution_id}, _from, state) do
    {reply, next_state} = update_entity(state, :executions, execution_id, &Executions.finish/1)
    {:reply, coerce_runtime_reply(reply), next_state}
  end

  def handle_call({:cancel_execution, execution_id}, _from, state) do
    {reply, next_state} = update_entity(state, :executions, execution_id, &Executions.cancel/1)

    reply =
      case reply do
        {:ok, execution} -> {:ok, Executions.list_item(execution)}
        {:error, reason} -> {:error, reason}
      end

    {:reply, reply, next_state}
  end

  def handle_call({:delegate_execution, parent_execution_id, request}, _from, state) do
    with {:ok, parent} <- fetch(state.executions, parent_execution_id),
         :ok <- ensure_non_terminal_parent(parent),
         {:ok, target} <- fetch(state.agent_instances, request["target_agent_instance_id"]),
         :ok <- ensure_ready_target(target),
         :ok <- ensure_non_self_target(parent, target) do
      execution_id = "exec-#{state.next_execution}"

      execution =
        Executions.new_execution(
          execution_id,
          target.agent_instance_id,
          :pending,
          parent.session_id,
          parent.execution_id,
          Map.fetch!(request, "input"),
          Map.get(request, "references", []),
          parent.context.session_material,
          %{
            "parent_execution_id" => parent.execution_id,
            "parent_explicit_input" => parent.context.explicit_input
          },
          Executions.synthetic_outcome(Map.fetch!(request, "input")),
          [
            Executions.event("execution.created", nil),
            Executions.event("execution.delegated", nil)
          ]
        )

      next_state = %{
        state
        | executions: Map.put(state.executions, execution_id, execution),
          next_execution: state.next_execution + 1
      }

      {:reply, {:ok, Executions.delegate_view(execution)}, next_state}
    else
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
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

  defp resolve_session(state, request) do
    case Map.get(request, "session_id") do
      nil ->
        {:ok, nil, nil}

      session_id ->
        case Map.fetch(state.sessions, session_id) do
          {:ok, %{state: :open, session_material: session_material}} ->
            {:ok, session_id, session_material}

          {:ok, _session} ->
            {:error, :invalid_state}

          :error ->
            {:error, :not_found}
        end
    end
  end

  defp coerce_runtime_reply({:ok, _execution}), do: :ok
  defp coerce_runtime_reply({:error, reason}), do: {:error, reason}

  defp ensure_non_terminal_parent(%{state: state})
       when state in [:completed, :failed, :canceled] do
    {:error, :invalid_state}
  end

  defp ensure_non_terminal_parent(_parent), do: :ok

  defp ensure_ready_target(%{state: :ready}), do: :ok
  defp ensure_ready_target(_target), do: {:error, :invalid_state}

  defp ensure_non_self_target(parent, target) do
    if parent.agent_instance_id == target.agent_instance_id do
      {:error, :invalid_state}
    else
      :ok
    end
  end

  defp sort_by_id(items, fun) do
    Enum.sort_by(items, fun)
  end
end
