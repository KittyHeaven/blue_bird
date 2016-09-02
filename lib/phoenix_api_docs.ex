defmodule PhoenixApiDocs do
  use Application

  def start(_type, []) do
    import Supervisor.Spec

    children = [
      worker(PhoenixApiDocs.ConnLogger, []),
    ]

    opts = [strategy: :one_for_one, name: PhoenixApiDocs.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start(options \\ []) do
    Application.start(:phoenix_api_docs)
    Enum.each options, fn {k, v} ->
      Application.put_env(:phoenix_api_docs, k, v)
    end
    :ok
  end

end
