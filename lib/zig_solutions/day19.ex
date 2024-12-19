defmodule Zig.Day19 do
  use Zig.Day, day: 19

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

  @doc """
  iex> Zig.Day19.part1(Zig.Day19.test_input())
  6

  iex> Zig.Day19.part1(Zig.Day19.input())
  324
  """
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  iex> Zig.Day19.part2(Zig.Day19.test_input())
  16

  iex> Zig.Day19.part2(Zig.Day19.input())
  575227823167869
  """
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end
end
