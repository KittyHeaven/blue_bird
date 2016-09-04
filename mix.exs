defmodule PhoenixApiDocs.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :phoenix_api_docs,
     version: @version,
     elixir: "~> 1.0",
     description: "PhoenixApiDocs generates API documentation from annotations in controllers actions and tests cases.",
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [registered: [PhoenixApiDocs.ConnLogger],
      mod: {PhoenixApiDocs, []},
      env: [
        docs_path: "docs"
      ]]
  end

  # Should work with all versions
  defp deps do
    [
      {:plug, ">= 0.0.0"},
      {:poison, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      contributors: ["Paul Smoczyk"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/smoku/phoenix_api_docs"}
    ]
  end
end
