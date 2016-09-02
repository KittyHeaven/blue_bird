defmodule PhoenixApiDocs.BlueprintWriter do

  def run(api_docs, path) do
    filename = Path.join(path, "api.apib")

    File.mkdir_p(path)
    File.write(filename, blueprint_text(api_docs))
  end

  defp blueprint_text(api_docs) do
    documentation_header = proces_documentation_header(api_docs)

    api_docs.routes
    |> Enum.sort_by(fn(route) -> route.group end)
    |> Enum.group_by(fn(route) -> route.group end)
    |> Enum.to_list
    |> Enum.reduce(documentation_header, fn({group_name, group_routes}, docs) ->
      docs
      <>
      """
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
      <>
      process_header(group, route)
      <>
      process_note(route)
      <>
      process_parameters(route)
      <>
      process_requests(route)
    end
  end

  defp process_header(group, route) do
    path = Regex.replace(~r/:([^\/]+)/, route.path, "{\\1}")

    """

    ## #{group} [#{path}]

    ### #{route.title} [#{route.method}]

    #{Map.get(route, :description, "")}

    """
  end

  defp process_note(%{note: note}) do
    """

    ::: note
    #{note}
    :::

    """
  end

  defp process_note(_), do: ""

  defp process_parameters(%{parameters: parameters}) when is_list(parameters) do
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

  defp process_parameters(_), do: ""

  defp process_requests(%{requests: requests}) when is_list(requests) do
    Enum.reduce requests, "", fn(request, docs) ->
      case Map.fetch(request, :body) do
        {:ok, body} ->
          """

          + Request json (application/json)
            #{body}
          """
        :error ->
          ""
      end
      <>
      case Map.fetch(request, :response) do
        {:ok, response} ->
          """

          + Response #{response.status}
            #{response.body}
          """
        :error ->
          ""
      end
    end
  end

  defp process_requests(_), do: ""

end
