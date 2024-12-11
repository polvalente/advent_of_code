defmodule Day11 do
  use Day, day: 11

  @test_input """
  0 1 10 99 999
  """

  def parse(input) do
    input
    |> split_lines()
    |> List.flatten()
    |> hd()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  iex> Day11.part1("0 1 10 99 999", 1, false)
  [0, 1, 1, 9, 9, 2024, 2021976]

  iex> Day11.part1("125 17", 6, false)
  [0, 0, 2, 2, 2, 2, 3, 4, 6, 6, 7, 8, 40, 40, 48, 48, 80, 96, 2024, 4048, 14168, 2097446912]

  iex> Day11.part1("125 17", 25, true)
  55312

  iex> Day11.part1(Day11.input(), 25, true)
  239714
  """
  def part1(input, num_ticks, count?) do
    data = parse(input)

    stone_map =
      data |> Enum.group_by(& &1) |> Enum.map(fn {k, v} -> {k, length(v)} end) |> Map.new()

    cache = %{}

    {stone_map, _} =
      Enum.reduce(1..num_ticks, {stone_map, cache}, fn _, {stone_map, cache} ->
        Enum.reduce(stone_map, {%{}, cache}, fn {stone, count}, {next_map, cache} ->
          {transformed, cache} = update_stone(stone, cache)

          next_map =
            Enum.reduce(transformed, next_map, fn new_stone, acc ->
              Map.update(acc, new_stone, count, &(&1 + count))
            end)

          {next_map, cache}
        end)
      end)

    if count? do
      Enum.reduce(stone_map, 0, fn {_, count}, acc -> acc + count end)
    else
      stone_map
      |> Enum.flat_map(fn {stone, count} -> List.duplicate(stone, count) end)
      |> Enum.sort()
    end
  end

  def update_stone(stone, cache) when is_map_key(cache, stone),
    do: {Map.fetch!(cache, stone), cache}

  def update_stone(stone, cache) do
    result =
      cond do
        stone == 0 ->
          [1]

        upd = replace_even_digits_by_two(stone) ->
          upd

        true ->
          [stone * 2024]
      end

    {result, Map.put(cache, stone, result)}
  end

  def replace_even_digits_by_two(stone) do
    n = floor(:math.log10(stone)) + 1

    if rem(n, 2) == 0 do
      mod = 10 ** div(n, 2)
      [div(stone, mod), rem(stone, mod)]
    end
  end
end
