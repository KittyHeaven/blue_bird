defmodule BlueBird.Request do
  @moduledoc """
  Defines the `Request` struct.
  """
  defstruct [
    :method,
    :path,
    :response,
    path_params: %{},
    body_params: %{},
    headers: [],
    query_params: %{}
  ]

  @typedoc """
  Type that represents the Request struct.
  """
  @type t :: %BlueBird.Request{
    method: String.t,
    path: String.t,
    headers: [{String.t, String.t}],
    path_params: %{optional(String.t) => String.t},
    body_params: %{optional(String.t) => String.t},
    query_params: %{optional(String.t) => String.t},
    response: BlueBird.Response.t
  }
end
