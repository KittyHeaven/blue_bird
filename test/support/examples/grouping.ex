defmodule BlueBird.Test.Support.Examples.Grouping do
  @moduledoc false

  alias BlueBird.{ApiDoc, Route}

  def api_doc do
    %ApiDoc{
      title: "Heavenly API",
      description: "This is the API description.\n\nIt may be helpful. Or not.",
      host: "https://youarguelikeaninformer.socrates",
      routes: [
        %Route{
          method: "GET",
          path: "/cats/:id",
          group: "Cats"
        },
        %Route{
          method: "POST",
          path: "/cats",
          group: "Cats"
        },
        %Route{
          method: "GET",
          path: "/airplanes/:id",
          group: "Airplanes"
        },
        %Route{
          method: "DELETE",
          path: "/cats/:id",
          group: "Cats"
        },
        %Route{
          method: "DELETE",
          path: "/airplanes/:id",
          group: "Airplanes"
        },
        %Route{
          method: "GET",
          path: "/cats",
          group: "Cats"
        },
        %Route{
          method: "GET",
          path: "/airplanes",
          group: "Airplanes"
        },
        %Route{
          method: "POST",
          path: "/airplanes",
          group: "Airplanes"
        },
        %Route{
          method: "PUT",
          path: "/cats/:id",
          group: "Cats"
        },
        %Route{
          method: "PUT",
          path: "/airplanes/:id",
          group: "Airplanes"
        }
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


    # Group Airplanes

    ## GET /airplanes

    ## POST /airplanes

    ## DELETE /airplanes/:id

    ## GET /airplanes/:id

    ## PUT /airplanes/:id

    # Group Cats

    ## GET /cats

    ## POST /cats

    ## DELETE /cats/:id

    ## GET /cats/:id

    ## PUT /cats/:id
    """
  end
end
