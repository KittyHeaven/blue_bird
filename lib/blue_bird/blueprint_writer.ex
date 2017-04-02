defmodule BlueBird.BlueprintWriter do

  @docs_path Application.get_env(:blue_bird, :docs_path, "docs")

  def run(api_docs) do
    File.mkdir_p(path())

    path()
    |> Path.join("api.apib")
    |> File.write(blueprint_text(api_docs))
  end

  defp path do
    Mix.Project.load_paths
    |> Enum.at(0)
    |> String.split("_build")
    |> Enum.at(0)
    |> Path.join(@docs_path)
  end

  defp blueprint_text(api_docs) do
    documentation_header = proces_documentation_header(api_docs)

    api_docs.routes
    |> Enum.sort_by(&(&1.group))
    |> Enum.group_by(&(&1.group))
    |> Enum.to_list()
    |> Enum.reduce(documentation_header, fn({group_name, group_routes}, docs) ->
      docs <> """
      # Group #{group_name}

      #{process_routes(group_name, group_routes)}
      """
    end)
  end

  defp proces_documentation_header(api_docs) do
    """
    FORMAT: 1A
    HOST: #{api_docs.host}

    # #{api_docs.title}

    #{api_docs.description}


    """
  end

  defp process_routes(group, routes) do
    Enum.reduce routes, "", fn(route, docs) ->
      docs
      <> process_doc_header(group, route)
      <> process_note(route)
      <> process_parameters(route)
      <> process_requests(route)
    end
  end

  defp process_doc_header(group, route) do
    path = Regex.replace(~r/:([^\/]+)/, route.path, "{\\1}")

    """

    ## #{group} [#{path}]

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

  defp process_parameters(%{parameters: parameters}) when is_list(parameters), do: print_parameters(parameters)
  defp process_parameters(_), do: ""
  defp print_parameters(parameters) do
    docs =
      """

      + Parameters
      """

    Enum.reduce parameters, docs, fn(param, docs) ->
      required_option = if Map.get(param, :required), do: "required", else: "optional"

      docs
      <>
      case Map.fetch(param, :example) do
        {:ok, example} ->
          """
            + #{param.name}: `#{example}` (#{param.type}, #{required_option}) - #{param.description}
          """
        :error ->
          """
            + #{param.name}: (#{param.type}, #{required_option}) - #{param.description}
          """
      end
    end
  end

  defp process_requests(%{requests: requests}) when is_list(requests), do: print_requests(requests)
  defp process_requests(_), do: ""
  defp print_requests(requests) do
    Enum.reduce requests, "", fn(request, docs) ->
      docs <> request_params(request) <> response_body(request)
    end
  end

  defp process_headers(headers) when is_list(headers), do: print_headers(headers)
  defp process_headers(_), do: ""
  defp print_headers(headers) do
    """
      + Headers
    """
    <>
    split_headers(headers)
    <>
    """

    """
  end

  defp split_headers(headers), do: split_headers(headers, "")
  defp split_headers([], l), do: l
  defp split_headers([h|t], l) do
    l = l <> """
        #{elem(h, 0)}: #{elem(h, 1)}
    """
    split_headers(t, l)
  end

  defp process_body(body) when is_binary(body), do: print_body(body)
  defp process_body(_), do: ""
  defp print_body(body) do
    """
      + Body
        #{body}

    """
  end

  defp request_params(request) do
    case Map.fetch(request, :params) do
      {:ok, params} ->
        """

        + Request json

        """
        <>
        process_headers(request.headers)
        <>
        process_body(params)
      :error ->
        ""
    end
  end

  defp response_body(request) do
    case Map.fetch(request, :response) do
      {:ok, response} ->
        """

        + Response #{response.status}

        """
        <>
        process_headers(response.headers)
        <>
        process_body(response.body)
      :error ->
        ""
    end
  end
end
