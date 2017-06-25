defmodule BlueBird.Test.Support.Examples.RouteTitles do
  @moduledoc false

  alias BlueBird.{ApiDoc, Request, Response, Route}

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      host: "https://youarguelikeaninformer.socrates/v1",
      routes: [
        %Route{
          method: "GET",
          title: "Ride",
          path: "/route-with-title",
          group: "Pony",
          requests: [%Request{
            response: %Response{
              status: 204,
              headers: [],
              body: ""
            }
          }]
        },
        %Route{
          method: "GET",
          path: "/route-without-title",
          group: "Pony",
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

  def apib do
    """
    FORMAT: 1A
    HOST: https://youarguelikeaninformer.socrates/v1

    # Heavenly API


    # Group Pony

    ## /route-with-title

    ### Ride [GET]

    + Response 204

    ## /route-without-title

    ### GET

    + Response 204
    """
  end

  def swagger do
    %{
      swagger: "2.0",
      info: %{
        title: "Heavenly API",
        version: "1"
      },
      host: "youarguelikeaninformer.socrates",
      basePath: "/v1",
      schemes: ["https"],
      paths: %{
        "/route-with-title" => %{
          "get" => %{
            summary: "Ride",
            tags: ["Pony"]
          }
        },
        "/route-without-title" => %{
          "get" => %{
            tags: ["Pony"]
          }
        }
      }
    }
  end
end
