defmodule Day1 do
  use Day, day: 1

  @external_resource "./day01/native.zig"

  use Zig,
    otp_app: :advent_of_code_2024,
    zig_code_path: "./day01/native.zig"

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

  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end
end
