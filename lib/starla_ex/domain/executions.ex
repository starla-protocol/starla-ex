defmodule StarlaEx.Domain.Executions do
  @states [:pending, :running, :blocked, :completed, :failed, :canceled]
  @synthetic_outcomes [:complete, :fail]

  defmodule EventRecord do
    @enforce_keys [:event]
    @derive {Jason.Encoder, only: [:event, :lifecycle_state]}
    defstruct [:event, :lifecycle_state]

    @type t :: %__MODULE__{
            event: String.t(),
            lifecycle_state: atom() | nil
          }
  end

  defmodule ContextSnapshot do
    @enforce_keys [:execution_id, :agent_instance_id, :explicit_input, :explicit_references]
    @derive {Jason.Encoder,
             only: [
               :execution_id,
               :agent_instance_id,
               :session_id,
               :explicit_input,
               :explicit_references,
               :session_material,
               :inherited_lineage_material,
               :tool_derived_material,
               :event_derived_material,
               :implementation_supplied
             ]}
    defstruct [
      :execution_id,
      :agent_instance_id,
      :session_id,
      :explicit_input,
      :explicit_references,
      :session_material,
      :inherited_lineage_material,
      :tool_derived_material,
      :event_derived_material,
      :implementation_supplied
    ]

    @type t :: %__MODULE__{
            execution_id: String.t(),
            agent_instance_id: String.t(),
            session_id: String.t() | nil,
            explicit_input: map(),
            explicit_references: [map()],
            session_material: map() | nil,
            inherited_lineage_material: map() | nil,
            tool_derived_material: map() | nil,
            event_derived_material: map() | nil,
            implementation_supplied: map() | nil
          }
  end

  defmodule Execution do
    @enforce_keys [
      :execution_id,
      :agent_instance_id,
      :state,
      :context,
      :recent_events,
      :synthetic_outcome
    ]
    @derive {Jason.Encoder,
             only: [
               :execution_id,
               :state,
               :agent_instance_id,
               :parent_execution_id,
               :session_id,
               :context,
               :recent_events
             ]}
    defstruct [
      :execution_id,
      :agent_instance_id,
      :state,
      :session_id,
      :parent_execution_id,
      :context,
      :recent_events,
      :synthetic_outcome
    ]

    @type t :: %__MODULE__{
            execution_id: String.t(),
            agent_instance_id: String.t(),
            state: atom(),
            session_id: String.t() | nil,
            parent_execution_id: String.t() | nil,
            context: ContextSnapshot.t(),
            recent_events: [EventRecord.t()],
            synthetic_outcome: :complete | :fail
          }
  end

  @spec new_execution(
          String.t(),
          String.t(),
          atom(),
          String.t() | nil,
          String.t() | nil,
          map(),
          [map()],
          map() | nil,
          map() | nil,
          atom(),
          [EventRecord.t()]
        ) :: Execution.t()
  def new_execution(
        execution_id,
        agent_instance_id,
        state,
        session_id,
        parent_execution_id,
        explicit_input,
        explicit_references,
        session_material,
        inherited_lineage_material,
        synthetic_outcome,
        recent_events
      )
      when state in @states and synthetic_outcome in @synthetic_outcomes do
    %Execution{
      execution_id: execution_id,
      agent_instance_id: agent_instance_id,
      state: state,
      session_id: session_id,
      parent_execution_id: parent_execution_id,
      context: %ContextSnapshot{
        execution_id: execution_id,
        agent_instance_id: agent_instance_id,
        session_id: session_id,
        explicit_input: explicit_input,
        explicit_references: explicit_references,
        session_material: session_material,
        inherited_lineage_material: inherited_lineage_material,
        tool_derived_material: nil,
        event_derived_material: nil,
        implementation_supplied: nil
      },
      recent_events: recent_events,
      synthetic_outcome: synthetic_outcome
    }
  end

  @spec event(String.t(), atom() | nil) :: EventRecord.t()
  def event(name, lifecycle_state) do
    %EventRecord{event: name, lifecycle_state: lifecycle_state}
  end

  @spec list_item(Execution.t()) :: map()
  def list_item(%Execution{} = execution) do
    %{
      execution_id: execution.execution_id,
      agent_instance_id: execution.agent_instance_id,
      state: execution.state,
      parent_execution_id: execution.parent_execution_id,
      session_id: execution.session_id
    }
  end

  @spec submit_work_view(Execution.t()) :: map()
  def submit_work_view(%Execution{} = execution) do
    %{
      execution_id: execution.execution_id,
      state: execution.state,
      session_id: execution.session_id
    }
  end

  @spec snapshot(Execution.t()) :: map()
  def snapshot(%Execution{} = execution) do
    %{
      execution_id: execution.execution_id,
      state: execution.state,
      agent_instance_id: execution.agent_instance_id,
      parent_execution_id: execution.parent_execution_id,
      session_id: execution.session_id,
      context: execution.context,
      recent_events: execution.recent_events
    }
  end

  @spec context_snapshot(Execution.t()) :: ContextSnapshot.t()
  def context_snapshot(%Execution{} = execution), do: execution.context

  @spec synthetic_outcome(map()) :: :complete | :fail
  def synthetic_outcome(%{"synthetic_outcome" => "failed"}), do: :fail
  def synthetic_outcome(_input), do: :complete

  @spec mark_running(Execution.t()) :: {:ok, Execution.t()} | {:error, :invalid_state}
  def mark_running(%Execution{state: :pending} = execution) do
    {:ok,
     %{
       execution
       | state: :running,
         recent_events: execution.recent_events ++ [event("execution.state_changed", :running)]
     }}
  end

  def mark_running(%Execution{}), do: {:error, :invalid_state}

  @spec finish(Execution.t()) :: {:ok, Execution.t()} | {:error, :invalid_state}
  def finish(%Execution{state: :running, synthetic_outcome: :complete} = execution) do
    {:ok,
     %{
       execution
       | state: :completed,
         recent_events: execution.recent_events ++ [event("execution.completed", :completed)]
     }}
  end

  def finish(%Execution{state: :running, synthetic_outcome: :fail} = execution) do
    {:ok,
     %{
       execution
       | state: :failed,
         recent_events: execution.recent_events ++ [event("execution.failed", :failed)]
     }}
  end

  def finish(%Execution{}), do: {:error, :invalid_state}

  @spec cancel(Execution.t()) :: {:ok, Execution.t()} | {:error, :invalid_state}
  def cancel(%Execution{state: state} = execution) when state in [:pending, :running] do
    {:ok,
     %{
       execution
       | state: :canceled,
         recent_events: execution.recent_events ++ [event("execution.canceled", :canceled)]
     }}
  end

  def cancel(%Execution{}), do: {:error, :invalid_state}
end
