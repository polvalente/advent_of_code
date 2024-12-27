defmodule Zig.Day do
  defmacro __using__(opts) do
    dbg(__CALLER__)
    basename = Path.basename(__CALLER__.file) |> String.trim_trailing(".ex")
    dir = Path.dirname(Path.relative_to(__CALLER__.file, Path.dirname(__CALLER__.file)))
    filename = Path.join(dir, basename <> ".zig")
    dir = Path.dirname(__CALLER__.file)
    full_filename = Path.join(dir, basename <> ".zig")

    {day, opts} = Keyword.pop!(opts, :day)

    zig_opts = [otp_app: :advent_of_code, zig_code_path: filename] ++ opts

    quote do
      use Day, day: unquote(day)
      use Zig, unquote(zig_opts)

      @external_resource unquote(full_filename)

      def filename, do: @external_resource
    end
  end
end
