defmodule BlueBird.Test.Support.Examples.NoRoutes do
  @moduledoc false

  # credo:disable-for-this-file Credo.Check.Readability.RedundantBlankLines

  alias BlueBird.ApiDoc

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      description: "This is the API description.\n\nIt may be helpful. Or not.",
      terms_of_service: "The terms.",
      host: "https://youarguelikeaninformer.socrates/v1",
      contact: [
        name: "Louis",
        url: "https://louis.louis.louis",
        email: "louis@louis.louis"
      ],
      license: [
        name: "Louis' License",
        url: "https://louis.louis/license"
      ],
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

    ## Terms of Service
    The terms.

    ## Contact
    Louis
    [https://louis.louis.louis](https://louis.louis.louis)
    [louis@louis.louis](mailto:louis@louis.louis)

    ## License
    Louis' License
    [https://louis.louis/license](https://louis.louis/license)


    """
  end

  def swagger do
    %{
      swagger: "2.0",
      info: %{
        title: "Heavenly API",
        description: "This is the API description.\n\n"
                     <> "It may be helpful. Or not.",
        version: "1",
        termsOfService: "The terms.",
        contact: %{
          name: "Louis",
          url: "https://louis.louis.louis",
          email: "louis@louis.louis"
        },
        license: %{
          name: "Louis' License",
          url: "https://louis.louis/license"
        }
      },
      host: "youarguelikeaninformer.socrates",
      basePath: "/v1",
      schemes: ["https"],
      paths: %{}
    }
  end
end
