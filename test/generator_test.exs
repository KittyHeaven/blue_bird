defmodule BlueBird.Test.GeneratorTest do
  require Logger

  use BlueBird.Test.Support.ConnCase

  import ExUnit.CaptureLog

  alias BlueBird.ConnLogger
  alias BlueBird.Generator
  alias BlueBird.Parameter
  alias BlueBird.Test.Support.Router

  @opts Router.init([])

  setup do
    ConnLogger.reset()
  end

  @tag :skip
  test "warns if contact url is invalid"

  @tag :skip
  test "warns if contact email is invalid"

  @tag :skip
  test "warns if license url is invalid"

  def find_route(api_docs, method, path) do
    Enum.find(api_docs.routes, fn x ->
      x.path == path && x.method == method
    end)
  end

  test "get_app_module/0" do
    app_module = Generator.get_app_module()
    assert app_module == BlueBird
  end

  test "get_router_module/1" do
    router_module = Generator.get_app_module() |> Generator.get_router_module()
    assert router_module == Router
  end

  describe "run/0" do
    test "includes all defined routes, uses default values" do
      Logger.disable(self())

      assert Generator.run() == %BlueBird.ApiDoc{
               description: """
               And the pilot likewise, in the strict sense of the term, is a
               ruler of sailors and not a mere sailor.
               """,
               terms_of_service: "The terms of service have changed.",
               host: "https://justiceisusefulwhenmoneyisuseless.fake",
               title: "Fancy API",
               routes: [
                 empty_route("GET", "/waldorf"),
                 empty_route("POST", "/waldorf"),
                 empty_route("GET", "/astoria"),
                 empty_route("POST", "/astoria"),
                 empty_route("GET", "/statler"),
                 empty_route("POST", "/statler/:id")
               ],
               groups: %{"Bobtails" => "The Bobtail Resource"}
             }
    end

    test "warns if api doc is missing for a route" do
      assert capture_log(fn ->
               Generator.run()
             end) =~ "No api doc defined for GET /undocumented."
    end

    test "warns if api docs are missing for all routes" do
      prev_conf = Application.get_env(:blue_bird, :router)

      Application.put_env(
        :blue_bird,
        :router,
        BlueBird.Test.Support.RouterUndocumented
      )

      assert capture_log(fn ->
               Generator.run()
             end) =~ "No api doc defined for GET /undocumented."

      Application.put_env(:blue_bird, :router, prev_conf)
    end

    test "includes headers" do
      :get
      |> build_conn("/waldorf")
      |> put_req_header("accept", "application/json")
      |> put_req_header("accept-language", "de-de")
      |> put_req_header("authorization", "Bearer abc")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")
      headers = List.first(route.requests).headers

      assert headers == [
               {"accept", "application/json"},
               {"accept-language", "de-de"},
               {"authorization", "Bearer abc"}
             ]
    end

    test "doesn't include empty headers" do
      :get
      |> build_conn("/waldorf")
      |> put_req_header("empty", "")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")
      headers = List.first(route.requests).headers

      assert headers == []
    end

    test "ignores configured headers" do
      prev_conf = Application.get_env(:blue_bird, :ignore_headers)
      Application.put_env(:blue_bird, :ignore_headers, ["ignore-me"])

      :get
      |> build_conn("/waldorf")
      |> put_req_header("ignore-me", "whatever")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")
      req_headers = List.first(route.requests).headers
      resp_headers = List.first(route.requests).response.headers

      refute Enum.member?(req_headers, {"ignore-me", "whatever"})
      refute Enum.member?(resp_headers, {"ignore-me", "whatever"})

      Application.put_env(:blue_bird, :ignore_headers, prev_conf)
    end

    test "ignores only request headers" do
      prev_conf = Application.get_env(:blue_bird, :ignore_headers)

      Application.put_env(:blue_bird, :ignore_headers, %{request: ["ignore-me"]})

      :get
      |> build_conn("/waldorf")
      |> put_req_header("ignore-me", "whatever")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")
      req_headers = List.first(route.requests).headers
      resp_headers = List.first(route.requests).response.headers

      refute Enum.member?(req_headers, {"ignore-me", "whatever"})
      assert Enum.member?(resp_headers, {"ignore-me", "whatever"})

      Application.put_env(:blue_bird, :ignore_headers, prev_conf)
    end

    test "ignores only response headers" do
      prev_conf = Application.get_env(:blue_bird, :ignore_headers)

      Application.put_env(:blue_bird, :ignore_headers, %{
        response: ["ignore-me"]
      })

      :get
      |> build_conn("/waldorf")
      |> put_req_header("ignore-me", "whatever")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")
      req_headers = List.first(route.requests).headers
      resp_headers = List.first(route.requests).response.headers

      assert Enum.member?(req_headers, {"ignore-me", "whatever"})
      refute Enum.member?(resp_headers, {"ignore-me", "whatever"})

      Application.put_env(:blue_bird, :ignore_headers, prev_conf)
    end

    test "uses values from api/3 macro" do
      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/statler")

      assert route.title == "Get Statler"
      assert route.description == "Description"
      assert route.note == "Note"
      assert route.warning == "Warning"
      assert route.parameters == []
    end

    test "uses controller name as default value for group" do
      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")

      assert route.group == "Test"
    end

    test "uses group name if defined" do
      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/astoria")

      assert route.group == "Bobtails"
    end

    test "includes params" do
      :post
      |> build_conn("/statler/137?s=poodle", Jason.encode!(%{betty: "white"}))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      route = Generator.run() |> find_route("POST", "/statler/:id")
      request = List.first(route.requests)

      assert request.query_params == %{"s" => "poodle"}
      assert request.path_params == %{"id" => "137"}
      assert request.body_params == %{"betty" => "white"}
    end

    test "includes all requests for a particular route and method" do
      :get
      |> build_conn("/waldorf")
      |> Router.call(@opts)
      |> ConnLogger.save()

      :get
      |> build_conn("/waldorf?betty=ford")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")

      assert length(route.requests) == 2
    end

    test "lists separate routes for the same path, but a different method" do
      :get
      |> build_conn("/waldorf")
      |> Router.call(@opts)
      |> ConnLogger.save()

      :post
      |> build_conn("/waldorf")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      api_docs = Generator.run()

      get_route = find_route(api_docs, "GET", "/waldorf")
      post_route = find_route(api_docs, "POST", "/waldorf")

      assert length(get_route.requests) == 1
      assert length(post_route.requests) == 1
    end

    test "includes request title" do
      :get
      |> build_conn("/waldorf")
      |> Router.call(@opts)
      |> ConnLogger.save(title: "Waldorf")

      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")
      request = hd(route.requests)

      assert request.title == "Waldorf"
    end

    test "includes response status, headers and body" do
      :get
      |> build_conn("/waldorf")
      |> Router.call(@opts)
      |> ConnLogger.save()

      Logger.disable(self())
      route = Generator.run() |> find_route("GET", "/waldorf")
      response = List.first(route.requests).response

      assert response.status == 200
      assert response.body == "{\"status\":\"ok\"}"

      assert response.headers == [
               {"cache-control", "max-age=0, private, must-revalidate"}
             ]
    end
  end

  defp empty_route("GET", "/waldorf") do
    %BlueBird.Route{
      description: nil,
      group: "Test",
      method: "GET",
      note: nil,
      warning: nil,
      parameters: [],
      path: "/waldorf",
      requests: [],
      title: "Get Waldorf"
    }
  end

  defp empty_route("GET", "/statler") do
    %BlueBird.Route{
      description: "Description",
      group: "Test",
      method: "GET",
      note: "Note",
      warning: "Warning",
      parameters: [],
      path: "/statler",
      requests: [],
      title: "Get Statler"
    }
  end

  defp empty_route("POST", "/waldorf") do
    %BlueBird.Route{
      description: nil,
      group: "Test",
      method: "POST",
      note: nil,
      warning: nil,
      parameters: [],
      path: "/waldorf",
      requests: [],
      title: "Post Waldorf"
    }
  end

  defp empty_route("POST", "/statler/:id") do
    %BlueBird.Route{
      description: nil,
      group: "Test",
      method: "POST",
      note: nil,
      warning: nil,
      parameters: [%Parameter{description: "ID", name: "id", type: "int"}],
      path: "/statler/:id",
      requests: [],
      title: "Post Statler"
    }
  end

  defp empty_route("GET", "/astoria") do
    %BlueBird.Route{
      description: nil,
      group: "Bobtails",
      method: "GET",
      note: nil,
      warning: nil,
      parameters: [],
      path: "/astoria",
      requests: [],
      title: "Get Astoria"
    }
  end

  defp empty_route("POST", "/astoria") do
    %BlueBird.Route{
      description: nil,
      group: "Bobtails",
      method: "POST",
      note: nil,
      warning: nil,
      parameters: [],
      path: "/astoria",
      requests: [],
      title: "Post Astoria"
    }
  end
end
