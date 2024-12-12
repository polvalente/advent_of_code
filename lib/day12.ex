defmodule Day12 do
  use Day, day: 12

  @test_input """
  RRRRIICCFF
  RRRRIICCCF
  VVRRRCCFFF
  VVRCCCJFFF
  VVVVCJJCFE
  VVIVCCJJEE
  VVIIICJJEE
  MIIIIIJJEE
  MIIISIJEEE
  MMMISSJEEE
  """

  def parse(input) do
    input
    |> split_lines()
    |> split_rows()
  end

  defp common(input) do
    data = parse(input)

    num_rows = length(data)
    num_cols = length(hd(data))

    data =
      data
    |> Enum.with_index(fn row, i ->
      Enum.with_index(row, fn char, j ->
        {{i, j}, char}
      end)
    end)
    |> List.flatten()
    |> Map.new()


    graph = :digraph.new()

    Enum.each(data, fn {{i, j}, char} ->
      :digraph.add_vertex(graph, {i, j}, char)
    end)

    Enum.each(data, fn {pos, _char} ->
      Enum.each(get_neighbors(pos, num_rows, num_cols, true), fn neighbor ->
        if data[pos] == data[neighbor] do
          :digraph.add_edge(graph, pos, neighbor)
          :digraph.add_edge(graph, neighbor, pos)
        end
      end)
    end)

    {data, num_rows, num_cols, graph}
  end

  @doc """
  iex> Day12.part1(Day12.test_input())
  1930

  iex> Day12.part1(Day12.input())
  """
  def part1(input) do
    {data, num_rows, num_cols, graph} = common(input)

    for region <- :digraph_utils.components(graph) do
      area = length(region)

      char = data[hd(region)]

      price =
        Enum.reduce(region, 0, fn pos, acc ->
          Enum.reduce(get_neighbors(pos, num_rows, num_cols, false), acc, fn pos, acc ->

            if data[pos] == char do
              acc
            else
              acc + area
            end
          end)
        end)

      price
    end
    |> Enum.sum()
  end

  @doc """
  iex> Day12.part2(Day12.test_input())
  1206

  iex> Day12.part2("AAAAAA\\nAAABBA\\nAAABBA\\nABBAAA\\nABBAAA\\nAAAAAA\\n")
  368

  iex> Day12.part2("EEEEE\\nEXXXX\\nEEEEE\\nEXXXX\\nEEEEE\\n")
  236

  iex> Day12.part2(Day12.input())
  862714
  """
  def part2(input) do
    {data, num_rows, num_cols, graph} = common(input)

    for region <- :digraph_utils.components(graph) do
      area = length(region)

      char = data[hd(region)]

      # We are going to build a secondary graph
      # in which each vertex of the region is split into 4 vertices
      # Then, we pair the edges whenever they are outer edges in the polygon,
      # effectively creating a graph that represents the polygon
      region_graph = :digraph.new()

      Enum.each(region, fn {i, j} ->
        [v0, v1, v2, v3] =
          [
            {i - 0.5, j - 0.5}, # up-left
            {i + 0.5, j - 0.5}, # down-left
            {i + 0.5, j + 0.5}, # down-right
            {i - 0.5, j + 0.5}, # up-right
          ]

        :digraph.add_vertex(region_graph, v0, char)
        :digraph.add_vertex(region_graph, v1, char)
        :digraph.add_vertex(region_graph, v2, char)
        :digraph.add_vertex(region_graph, v3, char)

        add_edge01? = data[{i, j - 1}] != char
        add_edge12? = data[{i + 1, j}] != char
        add_edge23? = data[{i, j + 1}] != char
        add_edge30? = data[{i - 1, j}] != char

        if add_edge01? do
          :digraph.add_edge(region_graph, v0, v1)
          :digraph.add_edge(region_graph, v1, v0)
        end

        if add_edge12? do
          :digraph.add_edge(region_graph, v1, v2)
          :digraph.add_edge(region_graph, v2, v1)
        end

        if add_edge23? do
          :digraph.add_edge(region_graph, v2, v3)
          :digraph.add_edge(region_graph, v3, v2)
        end

        if add_edge30? do
          :digraph.add_edge(region_graph, v3, v0)
          :digraph.add_edge(region_graph, v0, v3)
        end
      end)

      num_sides =
        Enum.map(:digraph.vertices(region_graph), fn vtx ->
          result =
            case :digraph.out_neighbours(region_graph, vtx) do
              [{i1, j1}, {i2, j2}] ->
                if i1 != i2 and j1 != j2 do
                  1
                else
                  0
                end

              [_, _, _, _] = n ->
                for {i1, j1} <- n, {i2, j2} <- n, abs(j1 - j2) == 1 and abs(i1 - i2) == 1 do
                  # The filter above is because we need to check if the diagonal traced is only across 1 tile.
                  # This is so that we can deal with complex polygons.

                  # Then, if the diagonal traced by the sub vertices falls on a different character tile,
                  # then we count it as a valid vertex

                  i = round((i1 + i2) / 2)
                  j = round((j1 + j2) / 2)

                  if data[{i, j}] != char do
                    1
                  else
                    0
                  end
                end
                |> Enum.sum()
                |> div(2)

              _ ->
                0
            end

          result
        end)
        |> Enum.sum()

      num_sides * area
    end
    |> Enum.sum()
  end

  def get_neighbors({i, j}, num_rows, num_cols, exclude_edges?) do
    neighbors = [
      {i - 1, j},
      {i + 1, j},
      {i, j - 1},
      {i, j + 1}
    ]

    if exclude_edges? do
      Enum.filter(neighbors, fn {i, j} ->
        i >= 0 and i < num_rows and j >= 0 and j < num_cols
      end)
    else
      neighbors
    end
  end
end
