defmodule BlueBird.Config do
  @moduledoc """
  Helper module to access the Blue Bird configuration.

  It now respects the sub app and will break with previous
  versions.
  """

  alias Mix.Project

  @spec get() :: list()
  def get() do
    Project.get().project()
    |> Keyword.get(:app)
    |> Application.get_env(:blue_bird, nil)
    |> case do
      nil ->
        Application.get_all_env(:blue_bird)
      conf ->
        conf
    end
  end

  @spec get(atom()) :: any()
  def get(key) do
    Keyword.get(get(), key)
  end

  @spec get(atom(), any()) :: any()
  def get(key, default) do
    Keyword.get(get(), key, default)
  end
end
