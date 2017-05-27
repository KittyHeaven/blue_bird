defmodule BlueBird.Response do
  @moduledoc """
  Defines the `Response` struct.
  """
  defstruct [
    status: 0,
    headers: [],
    body: ""
  ]

  @typedoc """
  Type that represents the Response struct.
  """
  @type t :: %BlueBird.Response{
    status: integer,
    headers: [{String.t, String.t}],
    body: String.t
  }
end
