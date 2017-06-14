defmodule BlueBird.Test.Support.Examples.Simple do
  @moduledoc false

  alias BlueBird.{ApiDoc, Request, Response, Route}

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      description: "This is the API description.\n\nIt may be helpful. Or not.",
      host: "https://youarguelikeaninformer.socrates",
      routes: [
        %Route{
          method: "GET",
          path: "/route-without-info-or-response"
        },
        %Route{
          method: "GET",
          path: "/route-with-simple-response",
          requests: [%Request{
            method: "GET",
            path: "/route-with-simple-response",
            response: %Response{
              status: 200,
              headers: [{"content-type", "text/plain"}],
              body: "Simple response."
            }
          }]
        },
        %Route{
          method: "GET",
          path: "/route-with-204-response",
          requests: [%Request{
            method: "GET",
            path: "/route-with-204-response",
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
    This is the API description.

    It may be helpful. Or not.


    ## /route-with-204-response

    ### GET

    + Response 204

    ## /route-with-simple-response

    ### GET

    + Response 200 (text/plain)

        + Body

                Simple response.

    ## /route-without-info-or-response

    ### GET
    """
  end
end
