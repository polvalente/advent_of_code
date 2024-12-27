defmodule AOC2024.Zig.Day1 do
  use Zig.Day, day: 1

  @test_input """
  3   4
  4   3
  2   5
  1   3
  3   9
  3   3
  """

  def parse(input) do
    input
    |> split_lines()
    |> split_rows("   ")
    |> Enum.map(fn [a, b] -> [String.to_integer(a), String.to_integer(b)] end)
  end

  @doc """
  iex> AOC2024.Zig.Day1.part1(AOC2024.Zig.Day1.test_input())
  11

  iex> AOC2024.Zig.Day1.part1(AOC2024.Zig.Day1.input())
  3508942
  """
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  iex> AOC2024.Zig.Day1.part2(AOC2024.Zig.Day1.test_input())
  31

  iex> AOC2024.Zig.Day1.part2(AOC2024.Zig.Day1.input())
  26593248
  """
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end
end
