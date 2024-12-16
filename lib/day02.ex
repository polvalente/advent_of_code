defmodule Day2 do
  use Day, day: 2

  @test_input """
  7 6 4 2 1
  1 2 7 8 9
  9 7 6 2 1
  1 3 2 4 5
  8 6 4 4 1
  1 3 6 7 9
  """

  def parse(input) do
    input
    |> split_lines()
    |> Enum.map(fn line ->
      line
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Nx.tensor()
    end)
  end

  @doc """
  ## Examples

      iex> Day2.part1(Day2.test_input())
      2

      iex> Day2.part1(Day2.input())
      510
  """
  def part1(input) do
    ts = parse(input)

    for t <- ts, reduce: 0 do
      acc ->
        solution(t) + acc
    end
  end

  defp solution(t) do
    import Nx
    diffs = diff(t)

    all_decreasing = all(less(diffs, 0))
    all_increasing = all(greater(diffs, 0))

    valid = logical_or(all_decreasing, all_increasing)

    safe = less_equal(Nx.abs(diffs), 3) |> all()

    valid
    |> logical_and(safe)
    |> Nx.sum()
    |> Nx.to_number()
  end

  @doc """
  ## Examples

      iex> Day2.part2(Day2.test_input())
      4

      iex> Day2.part2(Day2.input())
      553
  """
  def part2(input) do
    ts = parse(input)

    for t <- ts, reduce: 0 do
      acc ->
        if solution(t) == 1 do
          acc + 1
        else
          l = Nx.to_list(t)

          any_valid? =
            Enum.any?(0..(Nx.size(t) - 1), fn idx ->
              solution(List.delete_at(l, idx) |> Nx.tensor()) == 1
            end)

          if any_valid? do
            acc + 1
          else
            acc
          end
        end
    end
  end
end
