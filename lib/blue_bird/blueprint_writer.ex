defmodule BlueBird.BlueprintWriter do
  alias Mix.Project

  @docs_path Application.get_env(:blue_bird, :docs_path, "docs")

  def run(api_docs) do
    File.mkdir_p(path())

    path()
    |> Path.join("api.apib")
    |> File.write(blueprint_text(api_docs))
  end

  defp path do
    Project.load_paths
    |> Enum.at(0)
    |> String.split("_build")
    |> Enum.at(0)
    |> Path.join(@docs_path)
  end

  defp blueprint_text(api_docs) do
    documentation_header = print_documentation_header(api_docs)

    api_docs.routes
    |> Enum.sort_by(&(&1.group))
    |> Enum.group_by(&(&1.group))
    |> Enum.to_list()
    |> Enum.reduce(documentation_header, fn({group_name, group_routes}, docs) ->
      group_header = "\n# Group #{group_name}\n"

      processed_group_routes = group_routes
      |> Enum.sort_by(&(&1.path))
      |> Enum.group_by(&(&1.path))
      |> Enum.to_list()
      |> Enum.reduce(group_header, fn({res_name, res_routes}, docs) ->
        docs <> "\n## #{group_name} [#{Regex.replace(~r/:([^\/]+)/, res_name, "{\\1}")}]\n" <> process_routes(res_routes)
      end)
      docs <> processed_group_routes
    end)
  end

  defp print_documentation_header(api_docs) do
    """
    FORMAT: 1A
    HOST: #{api_docs.host}

    # #{api_docs.title}

    #{api_docs.description}


    """
  end

  defp process_routes(routes) do
    Enum.reduce(routes, "", fn(route, docs) ->
      docs
      <> process_doc_header(route)
      <> process_note(route)
      <> process_parameters(route)
      <> process_requests(route)
    end)
  end

  defp process_doc_header(route) do
    """

    ### #{route.title} [#{route.method}]

    #{Map.get(route, :description, "")}

    """
  end

  defp process_note(%{note: note}) when is_binary(note), do: print_note(note)
  defp process_note(_), do: ""
  defp print_note(note) do
    """

    ::: note
    #{note}
    :::

    """
  end

  defp process_parameters(%{parameters: [_|_] = parameters}) do
    docs = "\n+ Parameters\n"

    Enum.reduce parameters, docs, fn(param, docs) ->
      required_option =
        if Map.get(param, :required), do: "required", else: "optional"
      docs <> "\n    + #{param.name}: `-` (#{param.type}, #{required_option}) - #{param.description}"
    end
  end
  defp process_parameters(_), do: ""

  defp process_requests(%{requests: [_|_] = requests}) do
    requests
    |> Enum.sort_by(&(&1.response.status))
    |> Enum.split_with(fn(%{response: %{status: status}}) ->
         status >= 200 && status < 300
       end)
    |> Tuple.to_list()
    |> List.flatten()
    |> Enum.reduce("", fn(request, docs) ->
      docs <> process_request(request) <> process_response(request)
    end)
  end
  defp process_requests(_), do: ""

  defp process_headers([_|_] = headers) do
    """
        + Headers

            ```
    """
    <>
    split_headers(headers)
    <>
    """
            ```

    """
  end
  defp process_headers(_), do: ""

  defp split_headers(headers), do: split_headers(headers, "")
  defp split_headers([], l), do: l
  defp split_headers([h|t], l), do: split_headers(t, l <> "        #{elem(h, 0)}: #{elem(h, 1)}\n")

  defp process_body(body) when body == %{}, do: ""
  defp process_body(body) when is_map(body) do
    """
      + Body

          ```
          #{Poison.encode!(body)}
          ```

    """
  end
  defp process_body(_), do: ""

  defp process_request(request) do
    processed_headers     = process_headers(request.headers)
    processed_body_params = process_body(request.body_params)
    print_request(processed_headers, processed_body_params)
  end

  defp print_request("", ""), do: ""
  defp print_request(processed_headers, processed_body_params) do
    "\n\n+ Request json\n" <> processed_headers <> processed_body_params
  end

  defp process_response(request) do
    {:ok, response}       = Map.fetch(request, :response)
    processed_headers     = process_headers(response.headers)
    processed_body_params = process_body(Poison.decode!response.body)
    print_response(response, processed_headers, processed_body_params)
  end

  defp print_response(_, "", ""), do: ""
  defp print_response(response, processed_headers, processed_body_params) do
    "\n+ Response #{response.status}\n" <> processed_headers <> processed_body_params
  end
end
