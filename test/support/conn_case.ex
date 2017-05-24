defmodule BlueBird.Test.Support.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  """

  use ExUnit.CaseTemplate

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
end
