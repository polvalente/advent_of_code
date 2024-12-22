defmodule Day18 do
  use Day, day: 18

  @test_input """
  5,4
  4,2
  4,5
  3,0
  2,1
  6,3
  2,4
  1,5
  0,6
  3,3
  2,6
  5,1
  1,2
  5,5
  2,5
  6,5
  1,4
  0,4
  6,4
  1,1
  6,1
  1,0
  0,5
  1,6
  2,0
  """

  def parse(input) do
    input
    |> split_lines()
    |> Enum.map(fn line ->
      [left, right] = String.split(String.trim(line), ",", parts: 2)

      {String.to_integer(left), String.to_integer(right)}
    end)
  end

  @doc """
  iex> Day18.part1(Day18.test_input(), 6, 12)
  22

  iex> Day18.part1(Day18.input(), 70, 1024)
  316
  """
  def part1(input, max_valid_coord, num_dropped_bytes) do
    positions = parse(input)

    # positions are {x, y}, where x is horizontal and y is vertical, from the top left corner

    graph = common(positions, max_valid_coord, num_dropped_bytes)

    path = :digraph.get_short_path(graph, {0, 0}, {max_valid_coord, max_valid_coord})

    length(path) - 1
  end

  defp common(positions, max_valid_coord, num_dropped_bytes) do
    full_map =
      for x <- 0..max_valid_coord, y <- 0..max_valid_coord, reduce: %{} do
        acc ->
          Map.put(acc, {x, y}, true)
      end

    full_map =
      positions
      |> Enum.take(num_dropped_bytes)
      |> Enum.reduce(full_map, fn {x, y}, acc ->
        Map.delete(acc, {x, y})
      end)

    graph = :digraph.new()

    Enum.each(full_map, fn {coord, _} ->
      :digraph.add_vertex(graph, coord)
    end)

    Enum.each(full_map, fn {{x, y}, _} ->
      neighbors = [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]

      Enum.each(neighbors, fn neighbor ->
        if full_map[neighbor] do
          :digraph.add_edge(graph, {x, y}, neighbor)
          :digraph.add_edge(graph, neighbor, {x, y})
        end
      end)
    end)

    graph
  end

  @doc """
  iex> Day18.part2(Day18.test_input(), 6)
  {20, {6,1}}

  iex> Day18.part2(Day18.input(), 70)
  {2851, {45,18}}
  """
  def part2(input, max_valid_coord) do
    positions = parse(input)
    num_bytes = length(positions)
    index = binary_search(positions, max_valid_coord, 0, num_bytes)

    tuple = Enum.at(positions, index)
    {index, tuple}
  end

  defp binary_search(_positions, _max_valid_coord, low, high) when low + 1 >= high do
    low
  end

  defp binary_search(positions, max_valid_coord, low, high) do
    mid = div(low + high, 2)
    graph = common(positions, max_valid_coord, mid)

    if :digraph.get_short_path(graph, {0, 0}, {max_valid_coord, max_valid_coord}) do
      # Path exists, try dropping more bytes
      binary_search(positions, max_valid_coord, mid, high)
    else
      # No path exists, try dropping fewer bytes
      binary_search(positions, max_valid_coord, low, mid)
    end
  end
end
