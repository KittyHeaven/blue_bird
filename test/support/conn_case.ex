defmodule BlueBird.Test.Support.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  """

  use ExUnit.CaseTemplate

  alias BlueBird.Writer.Blueprint
  alias BlueBird.Writer.Swagger

  using do
    quote do
      use Phoenix.ConnTest
      import BlueBird.Test.Support.ConnCase
    end
  end

  defmacro assert_compile_time_raise(exception, message, fun) do
    quoted_fun = Macro.escape(fun)

    quote do
      assert_raise unquote(exception), unquote(message), fn ->
        Code.eval_quoted(unquote(quoted_fun))
      end
    end
  end

  defmacro assert_compile_time_raise(exception, func) do
    quoted_func = Macro.escape(func)

    quote do
      assert_raise unquote(exception), fn ->
        Code.eval_quoted(unquote(quoted_func))
      end
    end
  end

  defmacro example_test(module) do
    quote do
      test "'#{unquote(module) |> module_to_title}' is rendered to apib" do
        output = Blueprint.generate_output(unquote(module).api_doc)
        assert output == unquote(module).apib
      end

      test "'#{unquote(module) |> module_to_title}' is rendered to swagger" do
        output = Swagger.generate_output(unquote(module).api_doc)
        assert output == Poison.encode!(unquote(module).swagger)
      end
    end
  end

  def module_to_title(module), do: module |> Module.split |> Enum.at(-1)
end
