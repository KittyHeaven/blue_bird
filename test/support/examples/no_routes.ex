defmodule BlueBird.Test.Support.Examples.NoRoutes do
  @moduledoc false

  alias BlueBird.ApiDoc

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      description: "This is the API description.\n\nIt may be helpful. Or not.",
      host: "https://youarguelikeaninformer.socrates/v1",
      routes: []
    }
  end

  def apib do
    """
    FORMAT: 1A
    HOST: https://youarguelikeaninformer.socrates/v1

    # Heavenly API
    This is the API description.

    It may be helpful. Or not.


    """
  end

  def swagger do
    %{
      swagger: "2.0",
      info: %{
        title: "Heavenly API",
        description: "This is the API description.\n\n"
                     <> "It may be helpful. Or not.",
        version: "1"
      },
      host: "youarguelikeaninformer.socrates",
      basePath: "/v1",
      schemes: ["https"],
      paths: %{}
    }
  end
end
