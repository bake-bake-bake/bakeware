defmodule BakewareUpdater.MixProject do
  use Mix.Project

  def project do
    [
      app: :bakeware_updater,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {BakewareUpdater.Application, []}
    ]
  end

  defp deps do
    [
      {:castore, "~> 0.1"},
      {:jason, "~> 1.2"},
      {:mint, "~> 1.0"},
      {:temp, "~> 0.4"}
    ]
  end
end
