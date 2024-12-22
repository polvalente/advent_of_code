defmodule Day21 do
  use Day, day: 21
  use Memoize

  @test_input """
  029A
  980A
  179A
  456A
  379A
  """

  def parse(input) do
    input
    |> split_lines()
  end

  @numeric %{
    "7" => {0, 0},
    "8" => {1, 0},
    "9" => {2, 0},
    "4" => {0, 1},
    "5" => {1, 1},
    "6" => {2, 1},
    "1" => {0, 2},
    "2" => {1, 2},
    "3" => {2, 2},
    " " => {0, 3},
    "0" => {1, 3},
    "A" => {2, 3}
  }

  @directional %{
    " " => {0, 0},
    "^" => {1, 0},
    "A" => {2, 0},
    "<" => {0, 1},
    "v" => {1, 1},
    ">" => {2, 1}
  }

  @doc """
  iex> Day21.part1(Day21.test_input())
  126384

  iex> Day21.part1(Day21.input())
  188384
  """
  def part1(input) do
    # Translated solution from https://github.com/LiquidFun/adventofcode/blob/main/2024/21/21.py

    for code <- parse(input), reduce: 0 do
      acc ->
        {int, "A"} = Integer.parse(code)
        acc + int * len(code, 3)
    end
  end

  @doc """
  iex> Day21.part2(Day21.test_input())
  154115708116294

  iex> Day21.part2(Day21.input())
  232389969568832
  """
  def part2(input) do
    for code <- parse(input), reduce: 0 do
      acc ->
        {int, "A"} = Integer.parse(code)
        acc + int * len(code, 26)
    end
  end

  defmemo path(start, target) do
    pad =
      if Map.has_key?(@numeric, start) and Map.has_key?(@numeric, target) do
        @numeric
      else
        @directional
      end

    {tx, ty} = pad[target]
    {sx, sy} = pad[start]

    dx = tx - sx
    dy = ty - sy

    yy =
      cond do
        dy > 0 -> String.duplicate("v", dy)
        dy < 0 -> String.duplicate("^", -dy)
        true -> ""
      end

    xx =
      cond do
        dx > 0 -> String.duplicate(">", dx)
        dx < 0 -> String.duplicate("<", -dx)
        true -> ""
      end

    {p0x, p0y} = pad[" "]

    bad_x = p0x - sx
    bad_y = p0y - sy

    if (dx > 0 or {bad_x, bad_y} == {dx, 0}) and {bad_x, bad_y} != {0, dy} do
      yy <> xx <> "A"
    else
      xx <> yy <> "A"
    end
  end

  defmemo len(code, depth) do
    case depth do
      0 ->
        byte_size(code)

      _ ->
        {_, s} =
          for <<c::binary-1 <- code>>, reduce: {0, 0} do
            {i, s} ->
              prev = binary_part(code, modular_index(i - 1, byte_size(code)), 1)

              current =
                prev
                |> path(c)
                |> len(depth - 1)

              {i + 1, s + current}
          end

        s
    end
  end

  defp modular_index(i, mod) do
    rem(rem(i + mod, mod) + mod, mod)
  end
end
