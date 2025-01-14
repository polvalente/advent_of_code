defmodule AOC2024.Zig.Day2 do
  use Zig.Day, day: 2

  @test_input """
  7 6 4 2 1
  1 2 7 8 9
  9 7 6 2 1
  1 3 2 4 5
  8 6 4 4 1
  1 3 6 7 9
  """

  def parse(input) do
    input
    |> split_lines()
    |> split_rows(" ")
    |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)
  end

  @doc """
  iex> AOC2024.Zig.Day2.part1(AOC2024.Zig.Day2.test_input())
  2

  iex> AOC2024.Zig.Day2.part1(AOC2024.Zig.Day2.input())
  510
  """
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  iex> AOC2024.Zig.Day2.part2(AOC2024.Zig.Day2.test_input())
  4

  iex> AOC2024.Zig.Day2.part2(AOC2024.Zig.Day2.input())
  553
  """
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end
end
