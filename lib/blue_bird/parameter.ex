defmodule BlueBird.Parameter do
  @moduledoc """
  Defines the `Parameter` struct.
  """
  defstruct [:name, :type, :description]

  @typedoc """
  Type that represents the Parameter struct.
  """
  @type t :: %BlueBird.Parameter{
    name: String.t,
    type: String.t,
    description: String.t
  }
end
