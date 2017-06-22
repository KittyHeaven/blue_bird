defmodule BlueBird.Test.Support.Examples.Parameters do
  @moduledoc false

  alias BlueBird.{ApiDoc, Parameter, Request, Response, Route}

  def api_doc do
    %ApiDoc{
      title: "Pastry API",
      host: "https://youarguelikeaninformer.socrates",
      routes: [
        %Route{
          method: "GET",
          path: "/pastry/:id/:type",
          requests: [
            %Request{
              method: "GET",
              path: "/pastry/:id/:type",
              headers: [],
              query_params: %{
                query: "walnuts"
              },
              response: %Response{
                status: 204,
                headers: [],
                body: ""
              }
            },
            %Request{
              method: "GET",
              path: "/pastry/:id/:type",
              headers: [],
              query_params: %{
                query: "raspberries",
                page: "2"
              },
              response: %Response{
                status: 204,
                headers: [],
                body: ""
              }
            }
          ],
          parameters: [
            %Parameter{
              name: "id",
              type: "int"
            },
            %Parameter{
              name: "name",
              type: "string",
              description: "The name of the pastry."
            },
            %Parameter{
              name: "type",
              type: "enum[string]",
              optional: true,
              example: "flaky",
              description: "The type of the pastry.",
              additional_desc: "All the common pastry types are supported.",
              default: "puff",
              members: [
                "flaky",
                "puff",
                "choux",
                "shortcrust",
                "puff",
                "phyllo",
                "hot water crust"
              ]
            }
          ]
        },
      ]
    }
  end

  def apib do
    """
    FORMAT: 1A
    HOST: https://youarguelikeaninformer.socrates

    # Pastry API


    ## /pastry/{id}/{type}{?page,query}

    ### GET

    + Parameters

        + id (int, required)

        + name (string, required) - The name of the pastry.

        + type: flaky (enum[string], optional) - The type of the pastry.

            All the common pastry types are supported.

            + Default: puff

            + Members
                + flaky
                + puff
                + choux
                + shortcrust
                + puff
                + phyllo
                + hot water crust

    + Response 204

    + Response 204
    """
  end

  def swagger do
    %{
      swagger: "2.0",
      info: %{
        title: "Pastry API",
        version: "1"
      },
      host: "youarguelikeaninformer.socrates",
      basePath: "/",
      schemes: ["https"],
      paths: %{
        "/pastry/{id}/{type}" => %{}
      }
    }
  end
end
