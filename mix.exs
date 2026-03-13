defmodule StarlaEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :starla_ex,
      version: "0.1.0",
      description: "Elixir reference claimant for starla-protocol",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {StarlaEx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end
end
