defmodule BlueBird.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :blue_bird,
      version: "0.1.0",
      elixir: "~> 1.3",
      description: "BlueBird generates API documentation from annotations in controllers actions and tests cases.",
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

  # Should work with all versions
  defp deps do
    [
      {:plug, ">= 1.3.0"},
      {:poison, ">= 3.0.0"},
      {:ex_doc, ">= 0.15.0", only: :dev}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      contributors: ["Paul Smoczyk", "Djordje Atlialp"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rhazdon/blue_bird"}
    ]
  end
end
