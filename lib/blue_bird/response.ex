defmodule BlueBird.Response do
  @moduledoc """
  Defines the `Response` struct.
  """
  defstruct [:status, :headers, :body]

  @typedoc """
  Type that represents the Response struct.

    * status: integer
    * headers: [{String.t, String.t}]
    * body: String.t
  """
  @type t :: %BlueBird.Response{
    status: integer,
    headers: [{String.t, String.t}],
    body: String.t
  }
end
