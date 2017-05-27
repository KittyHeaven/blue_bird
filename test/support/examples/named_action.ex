defmodule BlueBird.Test.Support.Examples.NamedAction do
  @moduledoc false

  alias BlueBird.{ApiDoc, Request, Response, Route}

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      host: "https://youarguelikeaninformer.socrates",
      routes: [
        %Route{
          method: "GET",
          title: "Ride",
          path: "/route-with-action-name",
          requests: [%Request{
            response: %Response{
              status: 204,
              headers: [],
              body: ""
            }
          }]
        },
      ]
    }
  end

  def output do
    """
    FORMAT: 1A
    HOST: https://youarguelikeaninformer.socrates

    # Heavenly API


    ## /route-with-action-name

    ### Ride [GET]

    + Request

    + Response 204
    """
  end
end
