defmodule Zig.Day14 do
  use Zig.Day, day: 14

  @test_input """
  p=0,4 v=3,-3
  p=6,3 v=-1,-3
  p=10,3 v=-1,2
  p=2,0 v=2,-1
  p=0,0 v=1,3
  p=3,0 v=-2,-2
  p=7,6 v=-1,-3
  p=3,0 v=-1,-2
  p=9,3 v=2,3
  p=7,3 v=-1,2
  p=2,4 v=2,-3
  p=9,5 v=-3,-3
  """

  @doc """
  iex> Zig.Day14.part1(Zig.Day14.test_input(), 11, 7)
  12

  iex> Zig.Day14.part1(Zig.Day14.input(), 101, 103)
  222062148
  """
  def part1(input, width, height) do
    solve_part1(input, width, height)
  end

  @doc """
  iex> Zig.Day14.part2(Zig.Day14.input(), 101, 103)
  7520
  """
  def part2(input, width, height) do
    solve_part2(input, width, height)
  end
end
