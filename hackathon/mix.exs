defmodule Hackathon.MixProject do
  use Mix.Project

  def project do
    [
      app: :hackathon,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Hackathon.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
  [
    {:jason, "~> 1.4"},      # Para manejar JSON
    {:uuid, "~> 1.1"}        # Para generar IDs únicos
  ]
  end

  defp escript do
    [main_module: Hackathon]
  end
end
