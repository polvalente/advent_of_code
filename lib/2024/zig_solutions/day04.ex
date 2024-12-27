defmodule AOC2024.Zig.Day4 do
  use Zig.Day, day: 4

  @test_input """
  MMMSXXMASM
  MSAMXMSMSA
  AMXSXMAAMM
  MSAMASMSMX
  XMASAMXAMM
  XXAMMXXAMA
  SMSMSASXSS
  SAXAMASAAA
  MAMMMXMMMM
  MXMXAXMASX
  """

  def parse(input) do
    input
    |> split_lines()
    |> Enum.map(fn row ->
      row
      |> String.trim()
      |> String.to_charlist()
    end)
  end

  @doc """
  iex> AOC2024.Zig.Day4.part1(AOC2024.Zig.Day4.test_input())
  18

  iex> AOC2024.Zig.Day4.part1(AOC2024.Zig.Day4.input())
  2434
  """
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  iex> AOC2024.Zig.Day4.part2(AOC2024.Zig.Day4.test_input())
  9

  iex> AOC2024.Zig.Day4.part2(AOC2024.Zig.Day4.input())
  1835
  """
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end
end
