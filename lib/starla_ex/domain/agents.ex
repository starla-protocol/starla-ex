defmodule StarlaEx.Domain.Agents do
  @definition_states [:enabled, :disabled, :deleted]
  @instance_states [:ready, :paused, :terminated]

  defmodule AgentDefinition do
    @enforce_keys [:agent_definition_id, :state]
    @derive {Jason.Encoder, only: [:agent_definition_id, :state]}
    defstruct [:agent_definition_id, :state]

    @type t :: %__MODULE__{
            agent_definition_id: String.t(),
            state: :enabled | :disabled | :deleted
          }
  end

  defmodule AgentInstance do
    @enforce_keys [:agent_instance_id, :agent_definition_id, :state]
    @derive {Jason.Encoder, only: [:agent_instance_id, :agent_definition_id, :state]}
    defstruct [:agent_instance_id, :agent_definition_id, :state]

    @type t :: %__MODULE__{
            agent_instance_id: String.t(),
            agent_definition_id: String.t(),
            state: :ready | :paused | :terminated
          }
  end

  @spec new_definition(String.t(), atom()) :: AgentDefinition.t()
  def new_definition(agent_definition_id, state) when state in @definition_states do
    %AgentDefinition{
      agent_definition_id: agent_definition_id,
      state: state
    }
  end

  @spec new_instance(String.t(), String.t(), atom()) :: AgentInstance.t()
  def new_instance(agent_instance_id, agent_definition_id, state)
      when state in @instance_states do
    %AgentInstance{
      agent_instance_id: agent_instance_id,
      agent_definition_id: agent_definition_id,
      state: state
    }
  end

  @spec disable_definition(AgentDefinition.t()) ::
          {:ok, AgentDefinition.t()} | {:error, :invalid_state}
  def disable_definition(%AgentDefinition{state: :enabled} = definition) do
    {:ok, %{definition | state: :disabled}}
  end

  def disable_definition(%AgentDefinition{}), do: {:error, :invalid_state}

  @spec enable_definition(AgentDefinition.t()) ::
          {:ok, AgentDefinition.t()} | {:error, :invalid_state}
  def enable_definition(%AgentDefinition{state: :disabled} = definition) do
    {:ok, %{definition | state: :enabled}}
  end

  def enable_definition(%AgentDefinition{}), do: {:error, :invalid_state}

  @spec pause_instance(AgentInstance.t()) ::
          {:ok, AgentInstance.t()} | {:error, :invalid_state}
  def pause_instance(%AgentInstance{state: :ready} = instance) do
    {:ok, %{instance | state: :paused}}
  end

  def pause_instance(%AgentInstance{}), do: {:error, :invalid_state}

  @spec resume_instance(AgentInstance.t()) ::
          {:ok, AgentInstance.t()} | {:error, :invalid_state}
  def resume_instance(%AgentInstance{state: :paused} = instance) do
    {:ok, %{instance | state: :ready}}
  end

  def resume_instance(%AgentInstance{}), do: {:error, :invalid_state}

  @spec terminate_instance(AgentInstance.t()) ::
          {:ok, AgentInstance.t()} | {:error, :invalid_state}
  def terminate_instance(%AgentInstance{state: state} = instance)
      when state in [:ready, :paused] do
    {:ok, %{instance | state: :terminated}}
  end

  def terminate_instance(%AgentInstance{}), do: {:error, :invalid_state}
end
