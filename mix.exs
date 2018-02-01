defmodule Fryse.MixProject do
  use Mix.Project

  def project do
    [
      app: :fryse,
      version: "0.1.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :mix, :eex],
      mod: {Fryse.Application, []}
    ]
  end

  defp deps do
    [
      {:yaml_elixir, "~> 1.3"},
      {:earmark, "~> 1.2"}
    ]
  end

  def escript do
    [
      main_module: Fryse.CLI
    ]
  end
end
