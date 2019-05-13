defmodule BlueBird.Test.Support.UndocumentedController do
  @moduledoc """
  `BlueBird.Test.Support.UndocumentedController` simulates a Phoenix Framework controller.
  """
  use BlueBird.Controller
  use Phoenix.Controller

  @json_response Jason.encode!(%{status: "ok"})

  def catchall(conn, params) do
    body = Map.get(params, "body", @json_response)
    status = Map.get(params, "status", 200)
    conn = conn |> put_resp_header("ignore-me", "whatever")

    send_resp(conn, status, body)
  end
end
