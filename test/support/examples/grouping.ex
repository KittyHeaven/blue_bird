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
          path: "/dogs",
          group: "Pets"
        },
        %Route{
          method: "GET",
          path: "/cats",
          group: "Pets"
        },
        %Route{
          method: "GET",
          path: "/airplanes",
          group: "Vehicles"
        },
        %Route{
          method: "POST",
          path: "/dogs",
          group: "Pets"
        },
        %Route{
          method: "POST",
          path: "/carriages",
          group: "Vehicles"
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


    # Group Pets

    ## Resource /cats

    ### GET

    ## Resource /dogs

    ### GET

    ### POST

    # Group Vehicles

    ## Resource /airplanes

    ### GET

    ## Resource /carriages

    ### POST
    """
  end
end
