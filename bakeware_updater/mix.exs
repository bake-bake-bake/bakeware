defmodule BakewareUpdater.MixProject do
  use Mix.Project

  def project do
    [
      app: :sous_chef_api,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mint, "~> 1.0"},
      {:temp, "~> 0.4"}
    ]
  end
end
