defmodule Bakeware.MixProject do
  use Mix.Project

  @version "0.1.5"
  @source_url "https://github.com/bake-bake-bake/bakeware"

  def project do
    [
      app: :bakeware,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make | Mix.compilers()],
      make_targets: ["all"],
      make_clean: ["clean"],
      make_error_message: "",
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description(),
      dialyzer: [
        plt_add_apps: [:mix],
        flags: [:unmatched_returns, :error_handling, :race_conditions, :underspecs]
      ],
      preferred_cli_env: %{
        docs: :docs,
        "hex.publish": :docs,
        "hex.build": :docs
      }
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp description do
    "Bake your projects into a simple executable binary"
  end

  defp deps do
    [
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:elixir_make, "~> 0.6", runtime: false},
      {:ex_doc, "~> 0.22", only: :docs, runtime: false}
    ]
  end

  defp package do
    %{
      files: [
        "lib",
        "mix.exs",
        "Makefile",
        "README.md",
        "CHANGELOG.md",
        "LICENSE",
        "src/*.[ch]",
        "src/zstd"
      ],
      licenses: ["Apache-2.0"],
      links: %{
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md",
        "GitHub" => @source_url
      }
    }
  end

  defp docs do
    [
      extras: ["README.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      logo: "assets/logo.png"
    ]
  end
end
