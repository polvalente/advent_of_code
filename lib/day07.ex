defmodule Day7 do
  use Day, day: 7

  @test_input """
  190: 10 19
  3267: 81 40 27
  83: 17 5
  156: 15 6
  7290: 6 8 6 15
  161011: 16 10 13
  192: 17 8 14
  21037: 9 7 18 13
  292: 11 6 16 20
  """

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ":", trim: true))
    |> Enum.map(fn [num, rest] ->
      {String.to_integer(num),
       String.split(rest, " ", trim: true) |> Enum.map(&String.to_integer/1)}
    end)
  end

  @doc """
      iex> Day7.part1(Day7.test_input())
      3749

      iex> Day7.part1(Day7.input())
      1298103531759
  """
  def part1(input) do
    for {result, operands} <- parse(input) do
      out = is_possible?(result, operands, [&Kernel.+/2, &Kernel.*/2])

      if out == true do
        result
      else
        0
      end
    end
    |> Enum.sum()
  end

  @doc """
      iex> Day7.part2(Day7.test_input())
      11387

      iex> Day7.part2(Day7.input())
      140575048428831
  """
  def part2(input) do
    for {result, operands} <- parse(input) do
      out =
        is_possible?(result, operands, [&Kernel.+/2, &Kernel.*/2]) or
          is_possible?(result, operands, [&Kernel.+/2, &Kernel.*/2, &digit_concat/2])

      if out == true do
        result
      else
        0
      end
    end
    |> Enum.sum()
  end

  defp is_possible?(expected, operands, ops) do
    results =
      Enum.reduce(tl(operands), [hd(operands)], fn
        op, accs ->
          Enum.flat_map(accs, fn acc ->
            Enum.map(ops, &apply(&1, [acc, op]))
          end)
      end)

    expected in results
  end

  def digit_concat(a, b) do
    Integer.undigits(Integer.digits(a) ++ Integer.digits(b))
  end
end
