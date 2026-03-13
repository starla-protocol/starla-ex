defmodule StarlaEx.HTTP do
  @spec child_spec() :: Supervisor.child_spec()
  def child_spec do
    port = Application.get_env(:starla_ex, :http_port, 4747)

    {Bandit, plug: StarlaEx.HTTP.Router, scheme: :http, port: port}
  end
end
