defmodule BlueBird.Test.Writer.SwaggerTest do
  use BlueBird.Test.Support.ConnCase

  import BlueBird.Writer.Swagger

  alias BlueBird.ApiDoc
  alias BlueBird.Parameter

  describe "swagger_object/1" do
    test "includes swagger field" do
      assert swagger_object(%ApiDoc{})[:swagger] == "2.0"
    end

    test "includes info object" do
      assert Map.has_key?(swagger_object(%ApiDoc{}), :info)
    end

    test "includes host, base path and schemes" do
      api_doc = %ApiDoc{host: "https://somelikeithot.example.com/v1"}
      swagger = swagger_object(api_doc)
      assert swagger.host == "somelikeithot.example.com"
      assert swagger.schemes == ["https"]
      assert swagger.basePath == "/v1"

      api_doc = %ApiDoc{host: "https://example.com:1234"}
      swagger = swagger_object(api_doc)
      assert swagger.host == "example.com:1234"
      assert swagger.schemes == ["https"]
      assert swagger.basePath == "/"
    end

    test "includes path object" do
      assert Map.has_key?(swagger_object(%ApiDoc{}), :paths)
    end
    # test "includes consumes"
    # test "includes produces"
    # test "includes definitions object"
    # test "includes parameters definitions object"
    # test "includes responses definitions object"
    # test "includes security definitions object"
    # test "includes security requirement objects"
    # test "includes tags"
    # test "includes external documentation object"
  end

  describe "info object" do
    test "includes title" do
      api_doc = %ApiDoc{title: "The Title"}
      assert info_object(api_doc).title == "The Title"
    end

    test "includes description" do
      api_doc = %ApiDoc{description: "some description"}
      assert info_object(api_doc).description == "some description"
    end

    test "includes terms of service" do
      api_doc = %ApiDoc{terms_of_service: "tos"}
      assert info_object(api_doc).termsOfService == "tos"
    end

    test "does not include contact object if no values are set" do
      refute Map.has_key?(info_object(%ApiDoc{}), :contact)
    end

    test "includes contact object" do
      api_doc = %ApiDoc{contact: [name: "a name"]}
      assert Map.has_key?(info_object(api_doc), :contact)
    end

    test "includes license object" do
      api_doc = %ApiDoc{license: [name: "license name"]}
      assert Map.has_key?(info_object(api_doc), :license)
    end

    test "includes version" do
      assert info_object(%ApiDoc{}).version == "1"
    end
  end

  describe "contact object" do
    test "includes all values" do
      values = [name: "a name", url: "some url", email: "an email"]
      assert contact_object(values) == %{
        name: "a name",
        url: "some url",
        email: "an email"
      }
    end

    test "doesn't include empty values" do
      assert contact_object([]) == %{}
    end
  end

  describe "license object" do
    test "includes all values" do
      values = [name: "license name", url: "some url"]
      assert license_object(values) == %{
        name: "license name",
        url: "some url"
      }
    end

    test "doesn't include empty values" do
      assert license_object([]) == %{}
    end
  end

  describe "paths object" do
    test "includes path item objects" do
      routes = [
        %BlueBird.Route{method: "GET", path: "/candy"},
        %BlueBird.Route{method: "POST", path: "/candy"},
        %BlueBird.Route{method: "GET", path: "/brandy"},
        %BlueBird.Route{method: "PUT", path: "/brandy/:id"}
      ]

      objects = paths_object(routes)
      keys = Map.keys(objects)

      assert length(keys) == 3
      assert Enum.member?(keys, "/candy")
      assert Enum.member?(keys, "/brandy")
      assert Enum.member?(keys, "/brandy/{id}")

      assert objects["/candy"] |> Map.keys |> length() == 2
      assert objects["/brandy"] |> Map.keys |> length() == 1
      assert objects["/brandy/{id}"] |> Map.keys |> length() == 1
    end
  end

  describe "path item object" do
    test "includes operation objects" do
      routes = [
        %BlueBird.Route{method: "GET", path: "/candy"},
        %BlueBird.Route{method: "POST", path: "/candy"}
      ]

      object_keys = Map.keys(path_item_object(routes))

      assert length(object_keys) == 2
      assert Enum.member?(object_keys, "get")
      assert Enum.member?(object_keys, "post")
    end
  end

  describe "operation object" do
    test "includes summary and description" do
      route = %BlueBird.Route{
        method: "GET",
        path: "/candy",
        title: "the summary",
        description: "the description"
      }

      object = operation_object(route)

      assert object.summary == "the summary"
      assert object.description == "the description"
    end

    test "sets group as a tag" do
      route = %BlueBird.Route{
        method: "GET",
        path: "/candy",
        group: "sweets"
      }

      assert operation_object(route).tags == ["sweets"]
    end

    test "sets produces field" do
      route = %BlueBird.Route{
        method: "GET",
        path: "/candy",
        group: "sweets",
        requests: [
          %BlueBird.Request{
            response: %BlueBird.Response{
              headers: [{"content-type", "application/json"}],
            }
          },
          %BlueBird.Request{
            response: %BlueBird.Response{
              headers: [{"content-type", "text/plain"}],
            }
          }
        ]
      }

      assert operation_object(route).produces == [
        "application/json",
        "text/plain"
      ]
    end

    test "includes responses object" do
      route = %BlueBird.Route{
        method: "GET",
        path: "/candy"
      }

      assert operation_object(route).responses == %{}
    end

    test "includes parameters object" do
      route = %BlueBird.Route{
        method: "GET",
        path: "/candy",
        parameters: [
          %Parameter{
            name: "id",
            type: "int"
          }
        ]
      }

      object = operation_object(route)

      assert Map.has_key?(object, :parameters)
      assert length(object.parameters) == 1
      assert Enum.at(object.parameters, 0).name == "id"
    end
  end

  describe "parameter object" do
    parameter = %Parameter{name: "id", description: "the id"}

    object = parameter_object(parameter)
    assert object.name == "id"
    assert object.description == "the id"
  end
end
