defmodule GrowUnits.MixProject do
  use Mix.Project

  def project do
    [
      app: :grow_units,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {GrowUnits.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.3.0"},
      {:plug_cowboy, "~> 2.0"},
      {:hackney, "~> 1.15.2"},
      {:goth, "~> 1.1.0"},

      # optional, required by JSON middleware
      {:jason, ">= 1.0.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
