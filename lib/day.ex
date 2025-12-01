defmodule Day do
  defmacro __using__(opts) do
    day = opts[:day]

    quote do
      import Day
      use Memoize

      Module.register_attribute(__MODULE__, :test_input, accumulate: true, persist: true)

      def test_input do
        __MODULE__.__info__(:attributes)[:test_input] |> List.first()
      end

      def input(subdir \\ "") do
        File.read!("#{:code.priv_dir(:advent_of_code)}/#{subdir}/input#{unquote(day)}.txt")
      end
    end
  end

  def split_lines(string) do
    String.split(string, "\n", trim: true)
  end

  def split_rows(rows, separator \\ "") do
    Enum.map(rows, &String.split(&1, separator, trim: true))
  end
end
