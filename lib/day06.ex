defmodule Day6 do
  use Day, day: 6

  @test_input """
  ....#.....
  .........#
  ..........
  ..#.......
  .......#..
  ..........
  .#..^.....
  ........#.
  #.........
  ......#...
  """

  @doc """
      iex> Day6.part1(Day6.test_input())
      41

      iex> Day6.part1(Day6.input())
      5199
  """
  def part1(input) do
    matrix =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))

    num_rows = length(matrix)
    num_cols = length(hd(matrix))

    obstacles =
      for {row, i} <- Enum.with_index(matrix),
          {entry, j} <- Enum.with_index(row),
          entry == "#" or entry == "^",
          reduce: %{} do
        acc ->
          if entry == "#" do
            Map.put(acc, {i, j}, entry)
          else
            Map.put(acc, "start", {i, j})
          end
      end

    start = obstacles["start"]

    visited = loop1(start, :up, obstacles, MapSet.new([start]), num_rows, num_cols)

    MapSet.size(visited)
  end

  defp loop1(position, direction, obstacles, visited, num_rows, num_cols) do
    visited = MapSet.put(visited, position)
    {i, j} = next_position = move(position, direction)

    cond do
      Map.has_key?(obstacles, next_position) ->
        new_direction = turn_right(direction)
        loop1(position, new_direction, obstacles, visited, num_rows, num_cols)

      i < 0 or i >= num_rows or j < 0 or j >= num_cols ->
        visited

      true ->
        loop1(next_position, direction, obstacles, visited, num_rows, num_cols)
    end
  end

  defp move({i, j}, :up), do: {i - 1, j}
  defp move({i, j}, :down), do: {i + 1, j}
  defp move({i, j}, :left), do: {i, j - 1}
  defp move({i, j}, :right), do: {i, j + 1}

  defp turn_right(:up), do: :right
  defp turn_right(:right), do: :down
  defp turn_right(:down), do: :left
  defp turn_right(:left), do: :up

  @doc """
      iex> Day6.part2(Day6.test_input())
      6

      # iex> Day6.part2(Day6.input())
      # 1915
  """
  def part2(input) do
    matrix =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "", trim: true))

    num_rows = length(matrix)
    num_cols = length(hd(matrix))

    obstacles =
      for {row, i} <- Enum.with_index(matrix),
          {entry, j} <- Enum.with_index(row),
          entry == "#" or entry == "^",
          reduce: %{} do
        acc ->
          if entry == "#" do
            Map.put(acc, {i, j}, entry)
          else
            Map.put(acc, "start", {i, j})
          end
      end

    start = obstacles["start"]

    for i <- 0..(num_rows - 1),
        j <- 0..(num_cols - 1),
        results_in_cycle?(i, j, start, obstacles, num_rows, num_cols),
        reduce: 0 do
      acc -> acc + 1
    end
  end

  defp results_in_cycle?(i, j, start, obstacles, num_rows, num_cols) do
    obstacles = Map.put(obstacles, {i, j}, "#")

    loop2(start, :up, obstacles, MapSet.new(), num_rows, num_cols)
  end

  defp loop2(position, direction, obstacles, prev_visited, num_rows, num_cols) do
    visited = MapSet.put(prev_visited, {position, direction})
    {i, j} = next_position = move(position, direction)

    cond do
      prev_visited == visited ->
        true

      Map.has_key?(obstacles, next_position) ->
        new_direction = turn_right(direction)
        loop2(position, new_direction, obstacles, visited, num_rows, num_cols)

      i < 0 or i >= num_rows or j < 0 or j >= num_cols ->
        false

      true ->
        loop2(next_position, direction, obstacles, visited, num_rows, num_cols)
    end
  end
end
