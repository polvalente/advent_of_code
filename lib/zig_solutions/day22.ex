defmodule Zig.Day22 do
  use Zig.Day, day: 22

  @test_input """
  1
  10
  100
  2024
  """

  @test_input2 """
  1
  2
  3
  2024
  """

  def test_input2, do: @test_input2

  @doc """
  iex> Zig.Day22.part1(Zig.Day22.test_input())
  37327623

  iex> Zig.Day22.part1(Zig.Day22.input())
  19927218456
  """
  def part1(input) do
    input
    |> parse()
    |> solve_part1()
  end
end
