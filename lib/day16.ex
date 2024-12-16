defmodule Day16 do
  use Day, day: 16

  @test_input """
  ###############
  #.......#....E#
  #.#.###.#.###.#
  #.....#.#...#.#
  #.###.#####.#.#
  #.#.#.......#.#
  #.#.#####.###.#
  #...........#.#
  ###.#.#####.#.#
  #...#.....#.#.#
  #.#.#.###.#.#.#
  #.....#...#.#.#
  #.###.#.#.#.#.#
  #S..#.....#...#
  ###############
  """

  @test_input2 """
  #################
  #...#...#...#..E#
  #.#.#.#.#.#.#.#.#
  #.#.#.#...#...#.#
  #.#.#.#.###.#.#.#
  #...#.#.#.....#.#
  #.#.#.#.#.#####.#
  #.#...#.#.#.....#
  #.#.#####.#.###.#
  #.#.#.......#...#
  #.#.###.#####.###
  #.#.#...#.....#.#
  #.#.#.#####.###.#
  #.#.#.........#.#
  #.#.#.#########.#
  #S#.............#
  #################
  """

  def test_input2, do: @test_input2

  def parse(input) do
    cells =
      input
      |> split_lines()
      |> split_rows()
      |> Enum.with_index(fn row, i ->
        Enum.with_index(row, fn char, j ->
          case char do
            "#" -> {{i, j}, :wall}
            "." -> {{i, j}, nil}
            "S" -> [{{i, j}, :start}, {:start, {i, j}}]
            "E" -> [{{i, j}, :end}, {:end, {i, j}}]
          end
        end)
      end)
      |> List.flatten()
      |> Map.new()

    {start, cells} = Map.pop(cells, :start)
    {target, cells} = Map.pop(cells, :end)

    {cells, start, target}
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

  defp edge_cost({curr_i, curr_j}, {prev_i, prev_j}, orientation) do
    direction = {curr_i - prev_i, curr_j - prev_j}

    new_orientation =
      case direction do
        {1, 0} -> :south
        {-1, 0} -> :north
        {0, 1} -> :east
        {0, -1} -> :west
      end

    edge_cost =
      case {new_orientation, orientation} do
        # Going straight
        {same, same} -> 1
        # 90-degree turn
        {_, _} -> 1001
      end

    {edge_cost, new_orientation}
  end

  @doc """
  iex> Day16.part1(Day16.test_input())
  7036


  iex> Day16.part1(Day16.test_input2())
  11048

  iex> Day16.part1(Day16.input())
  """
  def part1(input) do
    {nodes, start, target} = parse(input)
    coords = Map.keys(nodes)
    num_rows = Enum.max_by(coords, fn {i, _} -> i end) |> elem(0)
    num_cols = Enum.max_by(coords, fn {_, j} -> j end) |> elem(1)

    # Initialize distances with {cost, orientation}
    initial_state = %{
      {:east, start} => 0,
      {:north, start} => 1000,
      {:south, start} => 1000
    }

    dijkstra(nodes, initial_state, MapSet.new(), target, num_rows, num_cols)
  end

  defp dijkstra(nodes, distances, visited, target, num_rows, num_cols) do
    # Find the unvisited node with minimum distance
    case find_min_unvisited(distances, visited) do
      nil ->
        :infinity

      {{orientation, current_pos} = current_state, current_cost} ->
        cond do
          # If we've reached the target, return the cost
          current_pos == target ->
            current_cost

          true ->
            visited = MapSet.put(visited, current_state)
            distances = Map.delete(distances, current_state)

            # Get neighbors and their costs
            neighbors =
              get_neighbors(current_pos, nodes, num_rows, num_cols, [
                {1, 0},
                {-1, 0},
                {0, 1},
                {0, -1}
              ])

            # Update distances for valid neighbors
            distances =
              Enum.reduce(neighbors, distances, fn {neighbor_coord, neighbor_value},
                                                   acc_distances ->
                if neighbor_value != :wall do
                  {edge_cost, new_orientation} =
                    edge_cost(neighbor_coord, current_pos, orientation)

                  new_state = {new_orientation, neighbor_coord}
                  new_cost = current_cost + edge_cost

                  if not MapSet.member?(visited, new_state) and
                       (not Map.has_key?(acc_distances, new_state) or
                          new_cost < Map.get(acc_distances, new_state)) do
                    Map.put(acc_distances, new_state, new_cost)
                  else
                    acc_distances
                  end
                else
                  acc_distances
                end
              end)

            dijkstra(nodes, distances, visited, target, num_rows, num_cols)
        end
    end
  end

  defp find_min_unvisited(distances, visited) do
    Enum.reduce_while(distances, nil, fn {state, cost} = entry, acc ->
      cond do
        MapSet.member?(visited, state) -> {:cont, acc}
        acc == nil -> {:cont, entry}
        cost < elem(acc, 1) -> {:cont, entry}
        true -> {:cont, acc}
      end
    end)
  end
end
