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

  @doc """
  iex> Day12.part1(Day12.test_input())
  1930

  iex> Day12.part1(Day12.input())
  """
  def part1(input) do
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

      # {char, area, perimeter, region}
      price
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
