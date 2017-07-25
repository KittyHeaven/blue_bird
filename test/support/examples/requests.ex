defmodule BlueBird.Test.Support.Examples.Requests do
  @moduledoc false

  alias BlueBird.{ApiDoc, Request, Response, Route}

  def api_doc do
    %ApiDoc{
      title: "Trendy API",
      host: "https://youarguelikeaninformer.socrates",
      routes: [
        %Route{
          method: "GET",
          path: "/request-headers",
          requests: [%Request{
            method: "GET",
            path: "/request-headers",
            body_params: %{"peter" => "paul", "mary" => "peter"},
            headers: [
              {"accept", "application/json"},
              {"authorization", "I'm a star"}
            ],
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

    # Trendy API


    ## /request-headers

    ### GET

    + Request 204

        + Headers

                accept: application/json
                authorization: I'm a star

        + Body

                {"peter":"paul","mary":"peter"}

    + Response 204
    """
  end
end
