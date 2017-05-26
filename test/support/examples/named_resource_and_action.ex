defmodule BlueBird.Test.Support.Examples.NamedResourceAndAction do
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
          resource: "Pony",
          path: "/route-with-resource-and-action-name",
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


    ## Resource Pony [/route-with-resource-and-action-name]

    ### Ride [GET]

        + Request

        + Response 204
    """
  end
end
