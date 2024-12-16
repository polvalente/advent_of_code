defmodule Zig.Day do
  defmacro __using__(opts) do
    filename = __CALLER__.file |> Path.split() |> List.last() |> String.trim_trailing(".ex")
    filename = "./" <> filename <> ".zig"

    {day, opts} = Keyword.pop!(opts, :day)

    zig_opts = [otp_app: :advent_of_code_2024, zig_code_path: filename] ++ opts

    quote do
      @external_resource unquote(filename)

      use Day, day: unquote(day)
      use Zig, unquote(zig_opts)
    end
  end
end
