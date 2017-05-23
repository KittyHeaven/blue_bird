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

    get     "/get",             Controller, :get
    get     "/get/:param",      Controller, :get_param
    post    "/post",            Controller, :post
    post    "/post/:param",     Controller, :post_param
    put     "/put",             Controller, :put
    patch   "/patch",           Controller, :patch
    delete  "/delete",          Controller, :delete
  end
end
