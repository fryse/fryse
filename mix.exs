defmodule Fryse.MixProject do
  use Mix.Project

  def project do
    [
      app: :fryse,
      version: "0.1.0",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      name: "Fryse",
      description: description(),
      package: package(),
      source_url: "https://github.com/fryse/fryse",
      homepage_url: "https://github.com/fryse/fryse",
      docs: [main: "Fryse"]
    ]
  end

  defp description do
    """
    Fryse is a Static Site Generator which aims to be generic and scriptable.
    """
  end

  defp package do
    [
      maintainers: ["Phillipp Ohlandt"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/fryse/fryse"}
    ]
  end

  def application do
    [
      extra_applications: [:logger, :mix, :eex],
      mod: {Fryse.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:yaml_elixir, "~> 2.0"},
      {:earmark, "~> 1.2"},
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:ex_doc, "~> 0.18.0", only: :dev, runtime: false}
    ]
  end

  def escript do
    [
      main_module: Fryse.CLI
    ]
  end
end
