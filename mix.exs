defmodule BlueBird.Mixfile do
  use Mix.Project

  @version "0.3.2"
  @url "https://github.com/KittyHeaven/blue_bird"
  @maintainers [
    "Djordje Atlialp",
    "Mathias Polligkeit"
  ]

  def project do
    [
      name: "BlueBird",
      app: :blue_bird,
      version: @version,
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test],
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      dialyzer: dialyzer()
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

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      # Static code analysis
      {:credo, "~> 0.8.0", only: [:dev, :test]},
      {:dialyxir, "~> 0.5.0", only: [:dev, :test], runtime: false},

      # Coverage
      {:excoveralls, "~> 0.7", only: [:test]},

      # Docs
      {:ex_doc, ">= 0.16.1", only: :dev},

      # Phoenix Framework
      {:phoenix, "~> 1.3.0-rc", optional: true},

      # Composable modules
      {:plug, ">= 1.3.0"},

      # JSON library
      {:poison, ">= 2.0.0"}
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      source_ref: "v#{@version}"
    ]
  end

  defp dialyzer do
    []
  end

  defp description do
    """
    BlueBird generates API documentation from annotations in controllers actions
    and tests cases.
    """
  end

  defp package do
    [
      maintainers: @maintainers,
      licenses: ["MIT"],
      links: %{"Github" => @url},
      files: ~w(lib) ++ ~w(mix.exs README.md LICENSE)
    ]
  end

  def blue_bird_info do
    [
      host: "https://justiceisusefulwhenmoneyisuseless.fake",
      title: "Fancy API",
      description: """
                   And the pilot likewise, in the strict sense of the term, is a
                   ruler of sailors and not a mere sailor.
                   """,
      terms_of_service: "The terms of service have changed."
    ]
  end
end
