defmodule PhoenixApiDocs.Controller do

  defmacro __using__(_) do
    quote do
      import PhoenixApiDocs.Controller, only: [api: 3]
    end
  end

  @doc """
  api :GET, "/posts/:id" do
    group "Posts"
    title "Show post"
    description "Show post by id"
    parameter :id, :integer, :required, "Post ID"
  end
  """
  defmacro api(method, path, do: block) do
    route_method = method |> atom_to_string |> String.upcase
    metadata = extract_metadata(block)
    group = metadata |> Keyword.get(:group, ["No group"]) |> List.first
    title = metadata |> Keyword.get(:title, ["Action"]) |> List.first
    description = metadata |> Keyword.get(:description, []) |> List.first
    parameters = extract_parameters(metadata)

    quote do
      def api_doc(unquote(route_method), unquote(path)) do
        %{
          group: unquote(group),
          title: unquote(title),
          description: unquote(description),
          method: unquote(route_method),
          path: unquote(path),
          parameters: unquote(Macro.escape(parameters))
        }
      end
    end
  end

  defp extract_metadata({:__block__, _, data}) do
    Enum.map data, fn({name, _line, params}) ->
      {name, params}
    end
  end

  defp extract_parameters(metadata) do
    Enum.reduce metadata, [], fn(parameter, list) ->
      case parameter do
        {:parameter, [name, type, :required, description]} ->
          list ++ [%{name: atom_to_string(name), type: atom_to_string(type), required: true, description: description}]
        {:parameter, [path, name, type, :required]} ->
          list ++ [%{name: atom_to_string(name), type: atom_to_string(type), required: true, description: ""}]
        {:parameter, [name, type, description]} ->
          list ++ [%{name: atom_to_string(name), type: atom_to_string(type), required: false, description: description}]
        {:parameter, [name, type]} ->
          list ++ [%{name: atom_to_string(name), type: atom_to_string(type), required: false, description: ""}]
        _ ->
          list
      end
    end
  end

  defp atom_to_string(atom_or_string) do
    cond do
      is_atom(atom_or_string) ->
        atom_or_string |> Atom.to_string
      true ->
        atom_or_string
    end
  end

end
