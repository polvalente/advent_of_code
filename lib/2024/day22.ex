defmodule AOC2024.Day22 do
  use Day, day: 22
  use Memoize

  @test_input """
  1
  10
  100
  2024
  """

  def parse(input) do
    input
    |> split_lines()
    |> Enum.map(&String.to_integer(String.trim(&1)))
  end

  @doc """
  iex> AOC2024.Day22.part1(AOC2024.Day22.test_input())
  37327623

  iex> AOC2024.Day22.part1(AOC2024.Day22.input())
  19927218456
  """
  def part1(input) do
    for secret <- parse(input), reduce: 0 do
      acc ->
        acc + Enum.reduce(1..2000, secret, fn _, secret -> next_secret(secret) end)
    end
  end

  def next_secret(secret) do
    secret =
      (secret * 64)
      |> Bitwise.bxor(secret)
      |> rem(16_777_216)

    secret =
      secret
      |> div(32)
      |> Bitwise.bxor(secret)
      |> rem(16_777_216)

    (secret * 2048)
    |> Bitwise.bxor(secret)
    |> rem(16_777_216)
  end

  @test_input2 """
  1
  2
  3
  2024
  """

  def test_input2, do: @test_input2

  @doc """
  iex> AOC2024.Day22.part2(AOC2024.Day22.test_input())
  24

  iex> AOC2024.Day22.part2(AOC2024.Day22.test_input2())
  23

  iex> AOC2024.Day22.part2(AOC2024.Day22.input())
  2189
  """
  def part2(input) do
    changes_and_prices =
      for secret <- parse(input) do
        {secrets, _} =
          Enum.map_reduce(1..2000, secret, fn _, secret ->
            s = next_secret(secret)
            {s, s}
          end)

        secrets = [secret | secrets]
        prices = Enum.map(secrets, fn secret -> rem(secret, 10) end)

        {changes, _} = Enum.map_reduce(prices, 0, fn price, acc -> {price - acc, price} end)

        changes = tl(changes)

        {changes, tl(prices)}
      end

    for {changes, prices} <- changes_and_prices, reduce: %{} do
      prices_per_sequence ->
        Enum.zip_reduce(
          [
            changes,
            Enum.drop(changes, 1),
            Enum.drop(changes, 2),
            Enum.drop(changes, 3),
            Enum.drop(prices, 3)
          ],
          {prices_per_sequence, MapSet.new()},
          # Map.new keeps the last value seen, so we need to keep only the first value seen
          fn [c1, c2, c3, c4, price], {prices_per_sequence, seen} ->
            tuple = {c1, c2, c3, c4}

            prices_per_sequence =
              if MapSet.member?(seen, tuple) do
                prices_per_sequence
              else
                Map.update(prices_per_sequence, tuple, price, &(&1 + price))
              end

            {prices_per_sequence, MapSet.put(seen, tuple)}
          end
        )
        |> elem(0)
    end
    # Find the entry with the highest price
    |> Enum.max_by(fn {_k, v} -> v end)
    # return the price
    |> elem(1)
  end
end
