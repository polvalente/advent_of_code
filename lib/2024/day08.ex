defmodule AOC2024.Day8 do
  use Day, day: 8

  @test_input """
  ............
  ........0...
  .....0......
  .......0....
  ....0.......
  ......A.....
  ............
  ............
  ........A...
  .........A..
  ............
  ............
  """

  def parse(input) do
    rows = String.split(input, "\n", trim: true)

    num_rows = length(rows)
    num_cols = byte_size(hd(rows))

    positions =
      rows
      |> Enum.map(&String.split(&1, "", trim: true))
      |> Enum.with_index(fn row, row_idx ->
        Enum.with_index(row, fn x, col_idx -> {{row_idx, col_idx}, x} end)
        |> Enum.reject(fn {_, x} -> x == "." end)
      end)
      |> List.flatten()
      |> Map.new()

    {positions, num_rows, num_cols}
  end

  @doc """
      iex> AOC2024.Day8.part1(AOC2024.Day8.test_input())
      14

      iex> AOC2024.Day8.part1(AOC2024.Day8.input())
      299
  """
  def part1(input) do
    {antennas, num_rows, num_cols} = parse(input)

    antennas_by_kind =
      Enum.group_by(antennas, fn {_pos, kind} -> kind end, fn {pos, _} -> pos end)

    for {_kind, positions} <- antennas_by_kind, reduce: MapSet.new() do
      antinodes ->
        ordered_positions = Enum.with_index(positions)

        for {{row1, col1}, idx1} <- ordered_positions,
            {{row2, col2}, idx2} <- ordered_positions,
            idx1 < idx2,
            reduce: antinodes do
          acc ->
            dx = row2 - row1
            dy = col2 - col1

            acc
            |> MapSet.put({row1 - dx, col1 - dy})
            |> MapSet.put({row2 + dx, col2 + dy})
        end
    end
    |> Enum.count(fn {row, col} -> row in 0..(num_rows - 1) and col in 0..(num_cols - 1) end)
  end

  @doc """
      iex> AOC2024.Day8.part2(AOC2024.Day8.test_input())
      34

      iex> AOC2024.Day8.part2(AOC2024.Day8.input())
      1032
  """
  def part2(input) do
    {antennas, num_rows, num_cols} = parse(input)

    antennas_by_kind =
      Enum.group_by(antennas, fn {_pos, kind} -> kind end, fn {pos, _} -> pos end)

    for {_kind, positions} <- antennas_by_kind, reduce: MapSet.new() do
      antinodes ->
        ordered_positions = Enum.with_index(positions)

        for {{row1, col1}, idx1} <- ordered_positions,
            {{row2, col2}, idx2} <- ordered_positions,
            idx1 < idx2,
            reduce: antinodes do
          acc ->
            dx = row2 - row1
            dy = col2 - col1

            acc
            |> MapSet.put({row1, col1})
            |> put_antinodes(&-/2, row1, col1, dx, dy, num_rows, num_cols)
            |> put_antinodes(&+/2, row1, col1, dx, dy, num_rows, num_cols)
        end
    end
    |> Enum.count()
  end

  defp put_antinodes(acc, op, row, col, dx, dy, num_rows, num_cols) do
    new_row = op.(row, dx)
    new_col = op.(col, dy)

    if new_row in 0..(num_rows - 1) and new_col in 0..(num_cols - 1) do
      acc
      |> MapSet.put({new_row, new_col})
      |> put_antinodes(op, new_row, new_col, dx, dy, num_rows, num_cols)
    else
      acc
    end
  end
end
