defmodule StarlaEx.HTTP do
  @spec child_spec() :: Supervisor.child_spec()
  def child_spec do
    port =
      case System.get_env("STARLA_EX_HTTP_PORT") do
        nil -> Application.get_env(:starla_ex, :http_port, 4747)
        value -> String.to_integer(value)
      end

    {Bandit, plug: StarlaEx.HTTP.Router, scheme: :http, port: port}
  end
end
