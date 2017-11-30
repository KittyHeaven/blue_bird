defmodule BlueBird.Test.Support.Examples.Grouping do
  @moduledoc false

  # credo:disable-for-this-file Credo.Check.Readability.RedundantBlankLines

  alias BlueBird.{ApiDoc, Request, Response, Route}

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      description: "This is the API description.\n\nIt may be helpful. Or not.",
      host: "https://youarguelikeaninformer.socrates",
      routes: [
        %Route{
          method: "GET",
          path: "/cats/:id",
          group: "Cats",
          requests: [
            %Request{
              method: "GET",
              path: "/cats/:id",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "POST",
          path: "/cats",
          group: "Cats",
          requests: [
            %Request{
              method: "POST",
              path: "/cats",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "GET",
          path: "/airplanes/:id",
          group: "Airplanes",
          requests: [
            %Request{
              method: "GET",
              path: "/airplanes/:id",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "DELETE",
          path: "/cats/:id",
          group: "Cats",
          requests: [
            %Request{
              method: "DELETE",
              path: "/cats/:id",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "DELETE",
          path: "/airplanes/:id",
          group: "Airplanes",
          requests: [
            %Request{
              method: "DELETE",
              path: "/airplanes/:id",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "GET",
          path: "/cats",
          group: "Cats",
          requests: [
            %Request{
              method: "GET",
              path: "/cats",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "GET",
          path: "/airplanes",
          group: "Airplanes",
          requests: [
            %Request{
              method: "GET",
              path: "/airplanes",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "POST",
          path: "/airplanes",
          group: "Airplanes",
          requests: [
            %Request{
              method: "POST",
              path: "/airplanes",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "PUT",
          path: "/cats/:id",
          group: "Cats",
          requests: [
            %Request{
              method: "PUT",
              path: "/cats/:id",
              response: %Response{status: 204}
            }
          ]
        },
        %Route{
          method: "PUT",
          path: "/airplanes/:id",
          group: "Airplanes",
          requests: [
            %Request{
              method: "PUT",
              path: "/airplanes/:id",
              response: %Response{status: 204}
            }
          ]
        }
      ],
      groups: %{"Cats" => "The Cat Resource"}
    }
  end

  def apib do
    """
    FORMAT: 1A
    HOST: https://youarguelikeaninformer.socrates

    # Heavenly API
    This is the API description.

    It may be helpful. Or not.


    # Group Airplanes

    ## /airplanes

    ### GET

    + Response 204

    ### POST

    + Response 204

    ## /airplanes/{id}

    ### DELETE

    + Response 204

    ### GET

    + Response 204

    ### PUT

    + Response 204

    # Group Cats

    The Cat Resource

    ## /cats

    ### GET

    + Response 204

    ### POST

    + Response 204

    ## /cats/{id}

    ### DELETE

    + Response 204

    ### GET

    + Response 204

    ### PUT

    + Response 204
    """
  end

  def swagger do
    %{
      swagger: "2.0",
      info: %{
        title: "Heavenly API",
        description:
          "This is the API description.\n\n" <> "It may be helpful. Or not.",
        version: "1"
      },
      host: "youarguelikeaninformer.socrates",
      basePath: "/",
      schemes: ["https"],
      paths: %{
        "/cats" => %{
          "get" => %{
            tags: ["Cats"],
            responses: %{}
          },
          "post" => %{
            tags: ["Cats"],
            responses: %{}
          }
        },
        "/cats/{id}" => %{
          "get" => %{
            tags: ["Cats"],
            responses: %{}
          },
          "delete" => %{
            tags: ["Cats"],
            responses: %{}
          },
          "put" => %{
            tags: ["Cats"],
            responses: %{}
          }
        },
        "/airplanes" => %{
          "get" => %{
            tags: ["Airplanes"],
            responses: %{}
          },
          "post" => %{
            tags: ["Airplanes"],
            responses: %{}
          }
        },
        "/airplanes/{id}" => %{
          "get" => %{
            tags: ["Airplanes"],
            responses: %{}
          },
          "delete" => %{
            tags: ["Airplanes"],
            responses: %{}
          },
          "put" => %{
            tags: ["Airplanes"],
            responses: %{}
          }
        }
      }
    }
  end
end
