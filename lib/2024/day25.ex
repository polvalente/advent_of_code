defmodule AOC2024.Day25 do
  use Day, day: 25
  use Memoize

  @test_input """
  #####
  .####
  .####
  .####
  .#.#.
  .#...
  .....

  #####
  ##.##
  .#.##
  ...##
  ...#.
  ...#.
  .....

  .....
  #....
  #....
  #...#
  #.#.#
  #.###
  #####

  .....
  .....
  #.#..
  ###..
  ###.#
  ###.#
  #####

  .....
  .....
  .....
  #....
  #.#..
  #.#.#
  #####
  """

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn lock_or_key ->
      kind =
        if String.starts_with?(lock_or_key, "#") do
          :lock
        else
          :key
        end

      grid =
        lock_or_key
        |> String.split("\n", trim: true)
        |> Enum.map(fn line ->
          line
          |> String.split("", trim: true)
          |> Enum.map(fn char -> char == "#" end)
        end)

      {kind, grid}
    end)
    |> Enum.split_with(fn {kind, _} -> kind == :key end)
  end

  @doc """
  iex> AOC2024.Day25.part1(AOC2024.Day25.test_input())
  3

  iex> AOC2024.Day25.part1(AOC2024.Day25.input())
  3320
  """
  def part1(input) do
    {keys, locks} = parse(input)

    for {:key, k} <- keys, {:lock, l} <- locks, reduce: MapSet.new() do
      acc ->
        if key_match?(k, l) do
          MapSet.put(acc, {k, l})
        else
          acc
        end
    end
    |> MapSet.size()
  end

  def key_match?(key, lock) do
    try do
      Enum.zip_with(key, lock, fn k_line, l_line ->
        Enum.zip_with(k_line, l_line, fn k, l ->
          if k and l do
            throw(:no_match)
          end
        end)
      end)

      true
    catch
      :no_match -> false
    end
  end
end
