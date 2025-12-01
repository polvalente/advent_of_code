defmodule AOC2025.Day1 do
  use Day, day: 1

  @test_input """
  L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82
  """

  def parse(input) do
    input
    |> split_lines()
    |> Enum.map(fn line ->
      case line do
        "L" <> distance -> -1 * String.to_integer(distance)
        "R" <> distance -> String.to_integer(distance)
      end
    end)
  end

  @doc """
  ## Examples

      iex> AOC2025.Day1.part1(AOC2025.Day1.test_input())
      {32, 3}

      iex> AOC2025.Day1.part1(AOC2025.Day1.input("2025"))
      {58, 1097}
  """
  def part1(input) do
    increments = parse(input)

    for inc <- increments, reduce: {50, 0} do
      {pos, zeros} ->
        new_pos = rem(rem(pos + inc, 100) + 100, 100)
        new_zeros = if new_pos == 0, do: zeros + 1, else: zeros
        {new_pos, new_zeros}
    end
  end

  @doc """
  ## Examples

      iex> AOC2025.Day1.part2(AOC2025.Day1.test_input())
      {32, 6}

      iex> AOC2025.Day1.part2(AOC2025.Day1.input("2025"))
      {58, 7101}
  """
  def part2(input) do
    increments = parse(input)

    {final_pos, zeros} =
      for inc <- increments, reduce: {50, 0} do
        {pos, zeros} ->
          new_pos = pos + inc

          crosses =
            cond do
              inc > 0 ->
                Integer.floor_div(new_pos, 100) - Integer.floor_div(pos, 100)

              inc < 0 ->
                Integer.floor_div(pos - 1, 100) - Integer.floor_div(new_pos - 1, 100)

              true ->
                0
            end

          {new_pos, zeros + crosses}
      end

    {Integer.mod(final_pos, 100), zeros}
  end
end
