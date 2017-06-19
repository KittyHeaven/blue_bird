defmodule BlueBird.Test.Support.Examples.NotesWarnings do
  @moduledoc false

  alias BlueBird.{ApiDoc, Route}

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      host: "https://youarguelikeaninformer.socrates",
      routes: [
        %Route{
          method: "GET",
          path: "/route-with-note-and-warning",
          note: "This is my route.",
          warning: "My route is fine."
        },
        %Route{
          method: "GET",
          path: "/route-with-description-and-note",
          description: "This is my route. My route is not my enemy.",
          note: "This is my route."
        },
      ]
    }
  end

  def apib do
    """
    FORMAT: 1A
    HOST: https://youarguelikeaninformer.socrates

    # Heavenly API


    ## /route-with-description-and-note

    ### GET
    This is my route. My route is not my enemy.

    ::: note
    This is my route.
    :::

    ## /route-with-note-and-warning

    ### GET

    ::: note
    This is my route.
    :::

    ::: warning
    My route is fine.
    :::
    """
  end

  def swagger do
    %{
      swagger: "2.0"
    }
  end
end
