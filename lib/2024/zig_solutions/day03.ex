defmodule AOC2024.Zig.Day3 do
  use Zig.Day, day: 3

  @test_input """
  xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
  """

  def parse(input) do
    String.trim(input)
  end

  @doc """
  iex> AOC2024.Zig.Day3.part1(AOC2024.Zig.Day3.test_input())
  161

  iex> AOC2024.Zig.Day3.part1(AOC2024.Zig.Day3.input())
  155955228
  """
  def part1(input) do
    input
    |> parse()
    |> solve(1)
  end

  @doc """
  iex> AOC2024.Zig.Day3.part2("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))")
  48

  iex> AOC2024.Zig.Day3.part2(AOC2024.Zig.Day3.input())
  100189366
  """
  def part2(input) do
    input
    |> parse()
    |> solve(2)
  end
end
