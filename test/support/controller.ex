defmodule BlueBird.Test.Support.Controller do
  @moduledoc """
  `BlueBird.Test.Support.Controller` simulates a Phoenix Framework controller.
  """
  use Phoenix.Controller
  use BlueBird.Controller

  @ok Poison.encode!(%{status: "ok"})

  api :GET, "/get" do
    group "Test"
    title "Test GET"
  end
  def get(conn, _params), do: send_resp(conn, 200, @ok)

  api :GET, "/get/:param" do
    group "Test"
    ressource "Camera"
    title "Test GET with param"
    parameter :param, :integer, "GET param"
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
    parameter :param, :integer, "Post param"
  end
  def post_param(conn, _params), do: send_resp(conn, 201, @ok)

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
