defmodule BlueBird.Test.Support.TestController do
  @moduledoc """
  `BlueBird.Test.Support.Controller` simulates a Phoenix Framework controller.
  """
  use BlueBird.Controller
  use Phoenix.Controller

  @json_response Poison.encode!(%{status: "ok"})

  api :GET, "/waldorf" do
    title "Get Waldorf"
  end

  api :POST, "/waldorf" do
    title "Post Waldorf"
  end

  api :GET, "/statler" do
    title "Get Statler"
    description "Description"
    note "Note"
    warning "Warning"
  end

  api_parameters :my_parameters do
    parameter :page, :number
    parameter :limit, :number, [default: 100]
    parameter :order_by, :string
  end

  api :POST, "/statler/:id" do
    title "Post Statler"
    parameter :id, :int, [description: "ID"]
    parameter_object :my_parameters
  end

  def catchall(conn, params) do
    body = Map.get(params, "body", @json_response)
    status = Map.get(params, "status", 200)

    send_resp(conn, status, body)
  end
end
