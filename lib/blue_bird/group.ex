defmodule BlueBird.Group do
  @moduledoc """
  Defines the `Group` struct.
  """
  defstruct [
    :name,
    :description
  ]

  @typedoc """
  Type that represents the Group struct.
  """
  @type t :: %BlueBird.Group{
    name: String.t | nil,
    description: String.t | nil
  }
end
