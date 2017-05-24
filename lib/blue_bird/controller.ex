defmodule BlueBird.Controller do
  defmacro __using__(_) do
    quote do
      import BlueBird.Controller, only: [api: 3]
    end
  end

  @doc """
  Generates the description of a route.

  - `method`: HTTP method (GET, POST, PUT etc.)
  - `url`: Route as defined in the Phoenix router
  - `group`: Resource group. Defaults to resource name guessed from controller
  name.
  - `resource`: Title for the resource. Defaults to the url.
  - `title`: Title for the action
  - `description`: Description of the route
  - `note`: Note
  - `parameter`: `name, type, :required, description`

  ## Example

      api :GET, "user/:id/posts/:pid" do
        group "Posts"
        resource "Single Post"
        title "Show post"
        description "Show post by ID"
        parameter :id, :integer, :required, "User ID"
        parameter :id, :integer, "Post ID"
        parameter :name, :string
      end
  """
  # TODO: If parameter is not required and not set, it will be another route.
  #       So no need for required/optional here?
  defmacro api(method, path, do: block) do
    method_str    = method_to_string(method)
    metadata      = extract_metadata(block)
    group         = extract_single_value(metadata, :group)
    resource      = extract_single_value(metadata, :resource)
    title         = extract_single_value(metadata, :title)
    description   = extract_single_value(metadata, :description)
    note          = extract_single_value(metadata, :note)
    parameters    = extract_parameters(metadata)

    quote do
      def api_doc(unquote(method_str), unquote(path)) do
        %{
          group:        unquote(group),
          resource:     unquote(resource),
          title:        unquote(title),
          description:  unquote(description),
          note:         unquote(note),
          method:       unquote(method_str),
          path:         unquote(path),
          parameters:   unquote(Macro.escape(parameters))
        }
      end
    end
  end

  defp method_to_string(method) do
    method
    |> to_string
    |> String.upcase
  end

  defp extract_metadata({:__block__, _, data}) do
    Enum.map data, fn({name, _line, params}) ->
      {name, params}
    end
  end
  defp extract_metadata({key, _, data}), do: [{key, data}]
  defp extract_metadata(nil), do: []

  defp extract_single_value(metadata, key) do
    values = metadata |> Keyword.get(key)

    cond do
      is_nil(values) -> nil
      length(values) == 1 -> List.first(values)
      true -> raise ArgumentError,
              "Expected single value for #{key}, got #{length(values)}"
    end
  end

  defp extract_parameters(metadata) do
    metadata
    |> Keyword.get_values(:parameter)
    |> Enum.reduce([], fn(param, list) -> [param_to_map(param) | list] end)
    |> Enum.reverse
  end

  defp param_to_map([name, type, :required, description]) do
    %{
      name: to_string(name),
      type: to_string(type),
      required: true,
      description: description
    }
  end
  defp param_to_map([name, type, :required]) do
    %{
      name: to_string(name),
      type: to_string(type),
      required: true,
      description: nil
    }
  end
  defp param_to_map([name, type, description]) do
    %{
      name: to_string(name),
      type: to_string(type),
      required: false,
      description: description
    }
  end
  defp param_to_map([name, type]) do
    %{
      name: to_string(name),
      type: to_string(type),
      required: false,
      description: nil
    }
  end
end
