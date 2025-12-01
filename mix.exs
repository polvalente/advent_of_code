defmodule AOC2024.MixProject do
  use Mix.Project

  def project do
    [
      app: :advent_of_code,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: ["lib", "test/support"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nx, "~> 0.10"},
      {:zigler, "~> 0.13.3", runtime: false},
      {:exla, "~> 0.10"},
      {:polaris, "~> 0.1"},
      {:memoize, "~> 1.4.3"},
      {:libgraph, "~> 0.16.0"}
      # {:zigler, path: "/home/valente/coding/zigler"}
    ]
  end
end
