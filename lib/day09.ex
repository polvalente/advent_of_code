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

  def part2(input) do
    {full_data, _total_size} =
      input
      |> parse()
      |> Enum.with_index(fn size, id ->
        kind = if rem(id, 2) == 0, do: :file, else: :empty

        if kind == :file do
          {:file, div(id, 2), size}
        else
          {:empty, size}
        end
      end)
      |> List.flatten()
      |> Enum.map_reduce(0, fn
        {:file, id, size}, offset ->
          {{:file, id, offset, size}, offset + size}

        {:empty, size}, offset ->
          {{:empty, offset, size}, offset + size}
      end)

    grouped_data =
      Enum.group_by(full_data, &elem(&1, 0), fn
        {:empty, offset, size} -> {offset, size}
        {:file, id, offset, size} -> {offset, size, id}
      end)

    files = grouped_data[:file]

    fragmented_data =
      full_data
      |> Enum.map(fn
        {:empty, _, size} -> List.duplicate(nil, size)
        {:file, id, _, size} -> List.duplicate(id, size)
      end)
      |> List.flatten()

    files
    |> Enum.sort_by(fn {_, _, id} -> id end, :desc)
    |> defrag(fragmented_data)
    |> Enum.with_index()
    |> Enum.reduce(0, fn {item, index}, sum ->
      if item != nil, do: sum + item * index, else: sum
    end)
  end

  defp defrag(files, fragmented_data) do
    Enum.reduce(files, fragmented_data, fn {offset, size, _id}, acc ->
      case find_hole(acc, offset, size) do
        nil ->
          acc

        {empty_idx, _empty_size} ->
          acc =
            Enum.reduce(0..(size - 1), acc, fn i, acc ->
              current_digit = Enum.fetch!(acc, offset + i)

              acc
              |> List.replace_at(empty_idx + i, current_digit)
              |> List.replace_at(offset + i, nil)
            end)

          acc
      end
    end)
  end

  defp find_hole(list, max_idx, size) do
    Enum.reduce_while(0..(max_idx - 1), list, fn idx, [h | t] = l ->
      if h == nil do
        hole = Enum.take(l, size)

        if Enum.all?(hole, &(&1 == nil)) do
          {:halt, {:halted, {idx, size}}}
        else
          {:cont, t}
        end
      else
        {:cont, t}
      end
    end)
    |> case do
      {:halted, {idx, size}} -> {idx, size}
      _ -> nil
    end
  end

  def merge_empty_spaces(empty_spaces) do
    empty_spaces
    |> Enum.sort_by(fn {idx, _} -> idx end)
    |> Enum.scan(nil, fn
      item, nil ->
        item

      {current_idx, current_size}, {prev_idx, prev_size} ->
        if current_idx == prev_idx + prev_size do
          {prev_idx, prev_size + current_size}
        else
          {current_idx, current_size}
        end
    end)
    |> Map.new()
  end
end
