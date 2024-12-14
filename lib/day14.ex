defmodule Day14 do
  use Day, day: 14

  @test_input """
  p=0,4 v=3,-3
  p=6,3 v=-1,-3
  p=10,3 v=-1,2
  p=2,0 v=2,-1
  p=0,0 v=1,3
  p=3,0 v=-2,-2
  p=7,6 v=-1,-3
  p=3,0 v=-1,-2
  p=9,3 v=2,3
  p=7,3 v=-1,2
  p=2,4 v=2,-3
  p=9,5 v=-3,-3
  """

  def parse(input) do
    input
    |> split_lines()
    |> Enum.map(fn line ->
      [px0, py0, vx0, vy0] =
        String.split(line, ["p", "=", "v", " ", ","], trim: true)
        |> Enum.map(&String.to_integer/1)

      {px0, py0, vx0, vy0}
    end)
  end

  @doc """
  iex> Day14.part1(Day14.test_input(), 11, 7)
  12

  iex> Day14.part1(Day14.input(), 101, 103)
  222062148
  """
  def part1(input, max_x, max_y) do
    robots =
      for {px0, py0, vx0, vy0} <- parse(input), reduce: %{} do
        acc ->
          p = fn s0, v, t -> s0 + v * t end

          px = p.(px0, vx0, 100)
          py = p.(py0, vy0, 100)

          px = rem(rem(px, max_x) + max_x, max_x)
          py = rem(rem(py, max_y) + max_y, max_y)

          Map.update(acc, {px, py}, 1, fn count -> count + 1 end)
      end

    x2 = div(max_x, 2) - 1
    y2 = div(max_y, 2) - 1

    first_quadrant_ranges = {0..x2, 0..y2}
    second_quadrant_ranges = {(x2 + 2)..max_x, 0..y2}
    third_quadrant_ranges = {0..x2, (y2 + 2)..max_y}
    fourth_quadrant_ranges = {(x2 + 2)..max_x, (y2 + 2)..max_y}

    ranges = [
      first_quadrant_ranges,
      second_quadrant_ranges,
      third_quadrant_ranges,
      fourth_quadrant_ranges
    ]

    for {x_range, y_range} <- ranges, reduce: 1 do
      product ->
        product *
          Enum.reduce(robots, 0, fn {{x, y}, count}, acc ->
            if x in x_range and y in y_range do
              acc + count
            else
              acc
            end
          end)
    end
  end
end
