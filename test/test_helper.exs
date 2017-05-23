defmodule TestRouter do
  @moduledoc """
  `TestRouter` simulates a Phoenix Framework router.
  """
  use Phoenix.Router
  import Plug.Conn
  import Phoenix.Controller

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    get     "/get",             TestController, :get
    get     "/get/:param",      TestController, :get_param
    post    "/post",            TestController, :post
    post    "/post/:param",     TestController, :post_param
    put     "/put",             TestController, :put
    patch   "/patch",           TestController, :patch
    delete  "/delete",          TestController, :delete
  end
end

defmodule TestController do
  @moduledoc """
  `TestController` simulates a Phoenix Framework controller.
  """
  use Phoenix.Controller
  use BlueBird.Controller

  @ok Poison.encode!(%{status: "ok"})

  api :GET, "/get" do
    group "Test"
    title "Test GET"
  end
  def get(conn, params), do: send_resp(conn, 200, @ok)

  api :GET, "/get/:param" do
    group "Test"
    title "Test GET with param"
    parameter :param, :integer, :required, "GET param"
  end
  def get_param(conn, _params), do: send_resp(conn, 200, @ok)

  api :POST, "/post" do
    group "Test"
    title "Test POST"
    note "This is a note"
  end
  def post(conn, _params), do: send_resp(conn, 201, @ok)

  api :POST, "/post/:param" do
    group "Test"
    title "Test POST with param"
    note "This is a note"
    parameter :param, :integer, :required, "Post param"
  end
  def post_param(conn, _params) do
    conn
    |> put_private(:my_body_1, Map.fetch(conn, :body_params))
    |> put_private(:my_body_2, Plug.Conn.read_body(conn))
    |> IO.inspect
    |> send_resp(201, @ok)
  end

  api :PUT, "/put" do
    group "Test"
    title "Test PUT"
  end
  def put(conn, _params), do: send_resp(conn, 201, @ok)

  api :PATCH, "/patch" do
    group "Test"
    title "Test PATCH"
  end
  def patch(conn, _params), do: send_resp(conn, 201, @ok)

  api :DELETE, "/delete" do
    group "Test"
    title "Test DELETE"
  end
  def delete(conn, _params), do: send_resp(conn, 204, @ok)
end

# Start ExUnit
ExUnit.start()
