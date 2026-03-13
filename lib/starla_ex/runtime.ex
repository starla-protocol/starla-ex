defmodule StarlaEx.Runtime do
  @delay_ms 25

  alias StarlaEx.Store

  @spec spawn_execution_progress(String.t()) :: pid()
  def spawn_execution_progress(execution_id) do
    {:ok, pid} =
      Task.start(fn ->
        Process.sleep(@delay_ms)

        if Store.mark_execution_running(execution_id) == :ok do
          Process.sleep(@delay_ms)
          _ = Store.finish_execution(execution_id)
        end
      end)

    pid
  end
end
