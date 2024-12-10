defmodule Zig.Day1 do
  use Day, day: 1

  use Zig,
    otp_app: :advent_of_code_2024,
    zig_code_path: "day01.zig"

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
  iex> Zig.Day1.part1(Zig.Day1.test_input())
  11

  iex> Zig.Day1.part1(Zig.Day1.input())
  3508942
  """
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  iex> Zig.Day1.part2(Zig.Day1.test_input())
  31

  iex> Zig.Day1.part2(Zig.Day1.input())
  26593248
  """
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end
end
