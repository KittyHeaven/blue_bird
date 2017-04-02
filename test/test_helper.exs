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

    get     "/get",       TestController, :get
    post    "/post",      TestController, :post
    put     "/put",       TestController, :put
    patch   "/patch",     TestController, :patch
    delete  "/delete",    TestController, :delete
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
  def get(conn, _params), do: send_resp(conn, 200, @ok)

  api :POST, "/post" do
    group "Test"
    title "Test POST"
    note "This is a note"
  end
  def post(conn, _params), do: send_resp(conn, 201, @ok)

  api :PUT, "/put" do
    group "Test"
    title "Test PUT"
  end
  def put(conn, _params), do: send_resp(conn, 201, @ok)

  api :PATCH, "/patch" do
    group "Test"
    title "Test PATCH"
    parameter :post_id, :integer, :required, "Post ID or slug"
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
