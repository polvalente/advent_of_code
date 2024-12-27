defmodule AOC2024.Zig.Day5 do
  use Zig.Day, day: 5

  @test_input """
  47|53
  97|13
  97|61
  97|47
  75|29
  61|13
  75|53
  29|13
  97|29
  53|29
  61|53
  97|53
  61|29
  47|13
  75|47
  97|75
  47|61
  75|61
  47|29
  75|13
  53|13

  75,47,61,53,29
  97,61,53,29,13
  75,29,13
  75,97,47,61,53
  61,13,29
  97,13,75,29,47
  """

  @doc """
  iex> AOC2024.Zig.Day5.part1(AOC2024.Zig.Day5.test_input())
  143

  iex> AOC2024.Zig.Day5.part1(AOC2024.Zig.Day5.input())
  5651
  """
  def part1(input) do
    solve_part1(input)
  end

  @doc """
      iex> AOC2024.Zig.Day5.part2(AOC2024.Zig.Day5.test_input())
      123

      iex> AOC2024.Zig.Day5.part2(AOC2024.Zig.Day5.input())
      4743
  """
  def part2(input) do
    solve_part2(input)
  end
end
