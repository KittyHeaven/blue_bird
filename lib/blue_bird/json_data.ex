defprotocol BlueBird.JSONData do
  @moduledoc """
  A protocol for request and response attributes.
  """

  @doc """
  Returns the JavaScript data type of the given data as string.

  ## Example

        iex> JSONData.type("string")
        "string"
        iex> JSONData.type(:yes)
        "string"
        iex> JSONData.type(1)
        "number"
  """
  @spec type(any) :: String.t
  def type(data)
end

defimpl BlueBird.JSONData, for: Atom do
  def type(_), do: "string"
end

defimpl BlueBird.JSONData, for: BitString do
  def type(_), do: "string"
end

defimpl BlueBird.JSONData, for: Float do
  def type(_), do: "number"
end

defimpl BlueBird.JSONData, for: Function do
  def type(_), do: "null"
end

defimpl BlueBird.JSONData, for: Integer do
  def type(_), do: "number"
end

defimpl BlueBird.JSONData, for: List do
  def type(_), do: "array"
end

defimpl BlueBird.JSONData, for: Map do
  def type(_), do: "object"
end

defimpl BlueBird.JSONData, for: PID do
  def type(_), do: "null"
end

defimpl BlueBird.JSONData, for: Port do
  def type(_), do: "null"
end

defimpl BlueBird.JSONData, for: Reference do
  def type(_), do: "null"
end

defimpl BlueBird.JSONData, for: Tuple do
  def type(_), do: "object"
end

defimpl BlueBird.JSONData, for: Any do
  def type(_), do: "null"
end
