defmodule BlueBird.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/rhazdon/blue_bird"
  @maintainers [
    "Djordje Atlialp"
  ]

  def project do
    [
      name: "BlueBird",
      app: :blue_bird,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      registered: [BlueBird.ConnLogger],
      mod: {BlueBird, []},
      env: [
        docs_path: "docs"
      ]
    ]
  end

  defp deps do
    [
      # Static code analysis
      {:credo, "~> 0.7.2", only: [:dev, :test]},

      # Coverage
      {:excoveralls, "~> 0.6.3", only: [:dev, :test]},

      # Docs
      {:ex_doc, ">= 0.15.0", only: :dev},

      # Composable modules
      {:plug, ">= 1.3.0"},

      # JSON library
      {:poison, ">= 3.0.0"}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp description do
    """
    BlueBird generates API documentation from annotations in controllers actions and tests cases.
    """
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{github: @url},
      files: ~w(lib) ++ ~w(mix.exs, README.md, LICENSE)
    ]
  end
end
