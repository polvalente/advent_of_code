defmodule Zig.Day4 do
  use Day, day: 4

  use Zig,
    otp_app: :advent_of_code_2024,
    zig_code_path: "day04.zig"

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
  iex> Zig.Day4.part1(Zig.Day4.test_input())
  18

  iex> Zig.Day4.part1(Zig.Day4.input())
  2434
  """
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end

  @doc """
  iex> Zig.Day4.part2(Zig.Day4.test_input())
  9

  iex> Zig.Day4.part2(Zig.Day4.input())
  1835
  """
  def part2(input) do
    input
    |> parse()
    |> solve_part2()
  end
end
