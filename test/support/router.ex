defmodule BlueBird.Test.Support.Router do
  @moduledoc """
  `BlueBird.Test.Support.Router` simulates a Phoenix Framework router.
  """
  use Phoenix.Router
  import Phoenix.Controller

  pipeline :api do
    plug Plug.Parsers, parsers: [:urlencoded, :multipart, :json],
                       pass:  ["*/*"],
                       json_decoder: Poison
    plug :accepts, ["json"]
  end

  scope "/", BlueBird.Test.Support do
    pipe_through :api

    get     "/waldorf",         TestController, :catchall
    post    "/waldorf",         TestController, :catchall
    get     "/statler",         TestController, :catchall
    post    "/statler/:id",     TestController, :catchall
    get     "/undocumented",    TestController, :catchall
  end
end
