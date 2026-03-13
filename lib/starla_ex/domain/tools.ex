defmodule StarlaEx.Domain.Tools do
  @states [:enabled, :disabled, :deleted]
  @outcomes [:completed, :failed]

  defmodule ToolDefinition do
    @enforce_keys [:tool_id, :state, :synthetic_outcome]
    @derive {Jason.Encoder, only: [:tool_id, :state]}
    defstruct [:tool_id, :state, :synthetic_outcome]

    @type t :: %__MODULE__{
            tool_id: String.t(),
            state: :enabled | :disabled | :deleted,
            synthetic_outcome: :completed | :failed
          }
  end

  @spec new_tool(String.t(), atom(), atom()) :: ToolDefinition.t()
  def new_tool(tool_id, state, synthetic_outcome)
      when state in @states and synthetic_outcome in @outcomes do
    %ToolDefinition{tool_id: tool_id, state: state, synthetic_outcome: synthetic_outcome}
  end

  @spec list_item(ToolDefinition.t()) :: map()
  def list_item(%ToolDefinition{} = tool) do
    %{tool_id: tool.tool_id, state: tool.state}
  end

  @spec invoke_result(ToolDefinition.t(), map()) :: map()
  def invoke_result(%ToolDefinition{synthetic_outcome: :completed} = tool, input) do
    %{
      tool_id: tool.tool_id,
      outcome: :completed,
      result: %{"echo" => input}
    }
  end

  def invoke_result(%ToolDefinition{synthetic_outcome: :failed} = tool, _input) do
    %{
      tool_id: tool.tool_id,
      outcome: :failed,
      result: %{"error" => "synthetic_failure"}
    }
  end
end
