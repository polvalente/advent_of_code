defmodule Day1 do
  use Day, day: 1

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
    |> Enum.map(fn line ->
      [a, b] = String.split(line, " ", trim: true)
      [String.to_integer(a), String.to_integer(b)]
    end)
    |> Nx.tensor(backend: EXLA.Backend)
  end

  @doc """
  ## Examples

      iex> Day1.part1(Day1.test_input())
      11

      iex> Day1.part1(Day1.input())
      3508942
  """
  def part1(input) do
    tensor = parse(input)

    tensor
    |> Nx.sort(axis: 0)
    |> Nx.diff(axis: 1)
    |> Nx.abs()
    |> Nx.sum()
    |> Nx.to_number()
  end

  @doc """
  ## Examples

      iex> Day1.part2(Day1.test_input())
      31

      iex> Day1.part2(Day1.input())
      26593248
  """
  def part2(input) do
    tensor = parse(input)

    left = tensor[[.., 0]]
    right = tensor[[.., 1]]

    weights = Nx.equal(Nx.new_axis(left, 1), Nx.new_axis(right, 0)) |> Nx.sum(axes: [1])

    Nx.dot(left, weights)
    |> Nx.to_number()
  end
end
