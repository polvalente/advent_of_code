defmodule DoctestCase do
  use ExUnit.CaseTemplate

  using opts do
    [h | parts] = Module.split(__CALLER__.module) |> Enum.reverse()

    mod = [String.trim_trailing(h, "Test") | parts] |> Enum.reverse() |> Module.concat()

    quote do
      use ExUnit.Case, async: true

      @moduletag unquote(opts[:moduletag])
      doctest unquote(mod)
    end
  end
end
