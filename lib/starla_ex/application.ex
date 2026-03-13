defmodule StarlaEx.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        StarlaEx.Store
      ] ++ http_children()

    opts = [strategy: :one_for_one, name: StarlaEx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp http_children do
    if Application.get_env(:starla_ex, :start_http, true) do
      [StarlaEx.HTTP.child_spec()]
    else
      []
    end
  end
end
