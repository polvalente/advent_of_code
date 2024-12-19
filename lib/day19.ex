defmodule Day19 do
  use Day, day: 19
  use Memoize

  @test_input """
  r, wr, b, g, bwu, rb, gb, br

  brwrr
  bggr
  gbbr
  rrbgbr
  ubwu
  bwurrg
  brgr
  bbrgwb
  """

  def parse(input) do
    [patterns, desired_designs] = String.split(input, "\n\n", parts: 2, trim: true)

    patterns = String.split(patterns, ",") |> Enum.map(&String.trim/1)

    desired_designs =
      desired_designs
      |> String.split("\n", trim: true)
      |> Enum.map(&(&1 |> String.trim()))

    {patterns, desired_designs}
  end

  @doc """
  iex> Day19.part1(Day19.test_input())
  6

  iex> Day19.part1(Day19.input())
  324
  """
  def part1(input) do
    {available_patterns, desired_designs} = parse(input)

    regex =
      available_patterns
      |> Enum.map_join("|", &"(?:#{&1})")
      |> then(&Regex.compile!("^(#{&1})+$"))

    Enum.count(desired_designs, fn design ->
      Regex.match?(regex, design)
    end)
  end

  @doc """
  iex> Day19.part2(Day19.test_input())
  16

  iex> Day19.part2(Day19.input())
  575227823167869
  """
  def part2(input) do
    {available_patterns, desired_designs} = parse(input)

    regex =
      available_patterns
      |> Enum.map_join("|", &"(?:#{&1})")
      |> then(&Regex.compile!("^(#{&1})+$"))

    Enum.filter(desired_designs, fn design ->
      Regex.match?(regex, design)
    end)
    |> Enum.reduce(0, fn design, acc ->
      acc + count_number_of_ways(design, available_patterns)
    end)
  end

  defmemo count_number_of_ways(str, patterns) do
    cond do
      str == "" ->
        1

      true ->
        patterns
        |> Enum.filter(&String.starts_with?(str, &1))
        |> Enum.map(fn pattern ->
          ["", rest] = String.split(str, pattern, parts: 2)
          count_number_of_ways(rest, patterns)
        end)
        |> Enum.sum()
    end
  end
end
