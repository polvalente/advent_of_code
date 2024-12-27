defmodule AOC2024.Zig.Day6 do
  use Zig.Day, day: 6

  @test_input """
  ....#.....
  .........#
  ..........
  ..#.......
  .......#..
  ..........
  .#..^.....
  ........#.
  #.........
  ......#...
  """

  @doc """
  iex> AOC2024.Zig.Day6.part1(AOC2024.Zig.Day6.test_input())
  41

  iex> AOC2024.Zig.Day6.part1(AOC2024.Zig.Day6.input())
  5199
  """
  def part1(input) do
    solve_part1(input)
  end

  @doc """
      iex> AOC2024.Zig.Day6.part2(AOC2024.Zig.Day6.test_input())
      6

      # commented out because it takes too long to run for doctests
      # iex> AOC2024.Zig.Day6.part2(AOC2024.Zig.Day6.input())
      # 1915
  """
  def part2(input) do
    solve_part2(input)
  end
end
