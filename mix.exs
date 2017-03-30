defmodule BlueBird.Mixfile do
  use Mix.Project

  def project do
    [
      app: :blue_bird,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: ExCoveralls],
      description: description(),
      package: package(),
      deps: deps()
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
      {:credo, "~> 0.7.2", only: :dev},

      # Coverage
      {:excoveralls, "~> 0.6.3"},

      # Docs
      {:ex_doc, ">= 0.15.0", only: :dev},

      # Composable modules
      {:plug, ">= 1.3.0"},

      # JSON library
      {:poison, ">= 3.0.0"}
    ]
  end

  defp description do
    """
    BlueBird generates API documentation from annotations in controllers actions and tests cases.
    """
  end

  defp package do
    [
      name: :blue_bird,
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      maintainers: ["Paul Smoczyk", "Djordje Atlialp"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/rhazdon/blue_bird"
      }
    ]
  end
end
