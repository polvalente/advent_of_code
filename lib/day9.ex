defmodule Day9 do
  use Day, day: 9

  @test_input """
  2333133121414131402
  """

  def parse(input) do
    [data] = split_rows([String.trim(input)])
    Enum.map(data, &String.to_integer/1)
  end

  def part1(input) do
    full_data =
      input
      |> parse()
      |> Enum.with_index(fn size, id ->
        kind = if rem(id, 2) == 0, do: :file, else: :empty

        if kind == :file do
          List.duplicate(div(id, 2), size)
        else
          List.duplicate(nil, size)
        end
      end)
      |> List.flatten()

    empty_indices =
      full_data
      |> Enum.with_index()
      |> Enum.filter(fn {item, _} -> item == nil end)
      |> Enum.map(fn {_, index} -> index end)

    filled_data =
      full_data
      |> Enum.with_index()
      |> Enum.filter(fn {item, _} -> item != nil end)
      |> Enum.map(fn {item, _} -> item end)

    num_filled_indices = length(filled_data)

    empty_indices = Enum.take_while(empty_indices, &(&1 < num_filled_indices))

    {_, result} =
      Enum.reduce(empty_indices, {Enum.reverse(filled_data), full_data}, fn target_position,
                                                                            {[source | sources],
                                                                             acc} ->
        {sources, List.replace_at(acc, target_position, source)}
      end)

    result = Enum.take(result, num_filled_indices)

    {_, sum} =
      Enum.reduce(result, {0, 0}, fn id, {i, sum} ->
        {i + 1, sum + id * i}
      end)

    sum
  end
end
