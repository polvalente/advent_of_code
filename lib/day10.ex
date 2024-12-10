defmodule Day10 do
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

  def part1(input) do
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
      neighbors = get_neighbors(coord, nodes_by_index, num_rows, num_cols, [{1, 0}, {-1, 0}, {0, 1}, {0, -1}])
      for {neighbor_coord, neighbor_value} <- neighbors, neighbor_value - value == 1 do
        :digraph.add_edge(graph, coord, neighbor_coord)
      end
    end)

    starts = Enum.filter(nodes_by_index, fn {_, value} -> value == 0 end)
    ends = Enum.filter(nodes_by_index, fn {_, value} -> value == 9 end)

    # starts = [{{0, 2}, 0}]

    for {start, _} <- starts, reduce: 0 do
      acc ->
        acc + Enum.count(ends, fn {target, _} ->
          :digraph.get_short_path(graph, start, target)
        end)
    end
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
end
