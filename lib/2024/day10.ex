defmodule AOC2024.Day10 do
  use Day, day: 10

  @test_input """
  89010123
  78121874
  87430965
  96549874
  45678903
  32019012
  01329801
  10456732
  """

  def parse(input) do
    input
    |> split_lines()
    |> split_rows()
    |> Enum.map(fn row ->
      Enum.map(row, &String.to_integer/1)
    end)
  end

  # 778
  def part1(input) do
    {graph, starts, ends} = common(input)

    for {start, _} <- starts, {target, _} <- ends, reduce: 0 do
      acc ->
        if :digraph.get_path(graph, start, target) do
          acc + 1
        else
          acc
        end
    end
  end

  # 1925
  def part2(input) do
    {graph, starts, ends} = common(input)

    for {start, _} <- starts, {target, _} <- ends, reduce: 0 do
      acc -> acc + count_paths(graph, start, target, MapSet.new())
    end
  end

  defp common(input) do
    data = parse(input)

    nodes_by_index =
      data
      |> Enum.with_index(fn row, row_idx ->
        Enum.with_index(row, fn x, col_idx ->
          {{row_idx, col_idx}, x}
        end)
      end)
      |> List.flatten()
      |> Map.new()

    num_rows = length(data)
    num_cols = length(hd(data))

    graph = :digraph.new()

    Enum.each(nodes_by_index, fn {coord, value} ->
      :digraph.add_vertex(graph, coord, [value])
    end)

    Enum.each(nodes_by_index, fn {coord, value} ->
      neighbors =
        get_neighbors(coord, nodes_by_index, num_rows, num_cols, [
          {1, 0},
          {-1, 0},
          {0, 1},
          {0, -1}
        ])

      for {neighbor_coord, neighbor_value} <- neighbors, neighbor_value - value == 1 do
        :digraph.add_edge(graph, coord, neighbor_coord)
      end
    end)

    starts = Enum.filter(nodes_by_index, fn {_, value} -> value == 0 end)
    ends = Enum.filter(nodes_by_index, fn {_, value} -> value == 9 end)

    {graph, starts, ends}
  end

  defp get_neighbors({x, y}, nodes, num_rows, num_cols, offsets) do
    Enum.flat_map(offsets, fn {xoff, yoff} ->
      x = x + xoff
      y = y + yoff

      if x >= 0 and x < num_cols and y >= 0 and y < num_rows do
        [{{x, y}, Map.get(nodes, {x, y})}]
      else
        []
      end
    end)
  end

  defp count_paths(graph, current, target, visited) do
    cond do
      current == target ->
        1

      current in visited ->
        0

      true ->
        next_vertices = :digraph.out_neighbours(graph, current)
        visited = MapSet.put(visited, current)

        Enum.reduce(next_vertices, 0, fn vertex, acc ->
          acc + count_paths(graph, vertex, target, visited)
        end)
    end
  end
end
