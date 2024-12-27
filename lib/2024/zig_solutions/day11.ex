defmodule AOC2024.Zig.Day11 do
  use Zig.Day, day: 11

  @test_input ""

  def parse(input) do
    input
    |> String.split([" ", "\n"], trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  iex> AOC2024.Zig.Day11.part1("0 1 10 99 999", 1)
  {7, [0, 1, 1, 9, 9, 2024, 2021976]}

  iex> AOC2024.Zig.Day11.part1("125 17", 6)
  {22, [0, 0, 2, 2, 2, 2, 3, 4, 6, 6, 7, 8, 40, 40, 48, 48, 80, 96, 2024, 4048, 14168, 2097446912]}

  iex> AOC2024.Zig.Day11.part1("125 17", 25, false)
  {55312, []}


  iex> AOC2024.Zig.Day11.part1(AOC2024.Zig.Day11.input(), 25, false)
  {239714, []}

  # This is part 2
  iex> AOC2024.Zig.Day11.part1(AOC2024.Zig.Day11.input(), 75, false)
  {284973560658514, []}
  """
  def part1(input, num_ticks, return_list \\ true) do
    input
    |> parse()
    |> solve(num_ticks, return_list)
  end
end
