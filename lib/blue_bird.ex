defmodule BlueBird do
  use Application

  def start(_type, []) do
    import Supervisor.Spec

    children = [
      worker(BlueBird.ConnLogger, []),
    ]

    opts = [strategy: :one_for_one, name: BlueBird.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start(options \\ []) do
    Application.start(:blue_bird)
    Enum.each options, fn {k, v} ->
      Application.put_env(:blue_bird, k, v)
    end
    :ok
  end

end
