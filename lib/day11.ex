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

  # This is part 2
  iex> Day11.part1(Day11.input(), 75, true)
  284973560658514
  """
  def part1(input, num_ticks, count?) do
    data = parse(input)

    stone_map =
      data |> Enum.group_by(& &1) |> Enum.map(fn {k, v} -> {k, length(v)} end) |> Map.new()

    cache = :ets.new(:cache, [:set, :protected])

    stone_map =
      Enum.reduce(1..num_ticks, stone_map, fn _, stone_map ->
        for {stone, count} <- stone_map, reduce: %{} do
          next_map ->
            transformed = update_stone(stone, cache)

            Enum.reduce(transformed, next_map, fn new_stone, acc ->
              Map.update(acc, new_stone, count, &(&1 + count))
            end)
        end
      end)

    if count? do
      Enum.reduce(stone_map, 0, fn {_, count}, acc -> acc + count end)
    else
      stone_map
      |> Enum.flat_map(fn {stone, count} -> List.duplicate(stone, count) end)
      |> Enum.sort()
    end
  end

  def update_stone(stone, cache) do
    cached = :ets.lookup(cache, stone)

    cond do
      cached != [] ->
        [{^stone, result}] = cached
        result

      stone == 0 ->
        :ets.insert(cache, {0, [1]})
        [1]

      upd = replace_even_digits_by_two(stone) ->
        :ets.insert(cache, {stone, upd})
        upd

      true ->
        res = [stone * 2024]
        :ets.insert(cache, {stone, res})
        res
    end
  end

  def replace_even_digits_by_two(stone) do
    n = floor(:math.log10(stone)) + 1

    if rem(n, 2) == 0 do
      mod = 10 ** div(n, 2)
      [div(stone, mod), rem(stone, mod)]
    end
  end
end
