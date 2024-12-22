defmodule Day20 do
  use Day, day: 20
  use Memoize

  @test_input """
  ###############
  #...#...#.....#
  #.#.#.#.#.###.#
  #S#...#.#.#...#
  #######.#.#.###
  #######.#.#...#
  #######.#.###.#
  ###..E#...#...#
  ###.#######.###
  #...###...#...#
  #.#####.#.###.#
  #.#...#.#.#...#
  #.#.#.#.#.#.###
  #...#...#...###
  ###############
  """

  def parse(input) do
    data =
      input
      |> split_lines()
      |> split_rows()

    num_rows = length(data)
    num_cols = length(hd(data))

    data =
      data
      |> Enum.with_index(fn row, i ->
        Enum.with_index(row, fn cell, j ->
          case cell do
            "S" ->
              [{:start, {i, j}}, {{i, j}, "S"}]

            "E" ->
              [{:end, {i, j}}, {{i, j}, "E"}]

            _ ->
              {{i, j}, cell}
          end
        end)
      end)
      |> List.flatten()
      |> Map.new()

    {start, data} = Map.pop(data, :start)
    {finish, data} = Map.pop(data, :end)

    {data, start, finish, num_rows, num_cols}
  end

  @doc """
  iex> Day20.part1(Day20.test_input(), 0)
  44

  iex> Day20.part1(Day20.input(), 100)
  1389
  """
  def part1(input, minimum) do
    part2(input, 2..2, minimum)
    # original solution below
    # {data, start, finish, num_rows, num_cols} = parse(input)

    # graph = build_graph(data, num_rows, num_cols)
    # path = :digraph.get_short_path(graph, start, finish)

    # path_by_idx = Enum.with_index(path, fn v, k -> {k, v} end) |> Map.new()

    # for a <- 0..(length(path) - 1),
    #     b <- (a + 3)..(length(path) - 1)//1,
    #     {ai, aj} <- [path_by_idx[a]],
    #     {bi, bj} <- [path_by_idx[b]],
    #     dist <- [abs(ai - bi) + abs(aj - bj)],
    #     dist == 2 do
    #   b - a - dist
    # end
    # |> Enum.count(&(&1 >= 100))
  end

  @doc """
  iex> Day20.part2(Day20.test_input(), 50)
  285

  iex> Day20.part2(Day20.input(), 100)
  1005068
  """
  def part2(input, allowed_cheat_range \\ 2..20, minimum) do
    {data, start, finish, num_rows, num_cols} = parse(input)

    graph = build_graph(data, num_rows, num_cols)
    path = :digraph.get_short_path(graph, start, finish)
    path_by_idx = Enum.with_index(path, fn v, k -> {k, v} end) |> Map.new()

    for a <- 0..(length(path) - 1),
        b <- (a + 3)..(length(path) - 1)//1,
        {ai, aj} <- [path_by_idx[a]],
        {bi, bj} <- [path_by_idx[b]],
        dist <- [abs(ai - bi) + abs(aj - bj)],
        dist in allowed_cheat_range,
        b - a - dist >= minimum,
        reduce: 0 do
      acc -> acc + 1
    end
  end

  defp build_graph(data, num_rows, num_cols) do
    graph = :digraph.new()

    for i <- 0..(num_rows - 1), j <- 0..(num_cols - 1), data[{i, j}] in [".", "S", "E"] do
      :digraph.add_vertex(graph, {i, j})
    end

    for i <- 0..(num_rows - 1),
        j <- 0..(num_cols - 1),
        neighbor <- [{i + 1, j}, {i - 1, j}, {i, j + 1}, {i, j - 1}],
        data[{i, j}] in [".", "S", "E"] and data[neighbor] in [".", "S", "E"] do
      :digraph.add_edge(graph, {i, j}, neighbor)
      :digraph.add_edge(graph, neighbor, {i, j})
    end

    graph
  end

  def print_path(data, path, num_rows, num_cols) do
    for i <- 0..(num_rows - 1) do
      line =
        for j <- 0..(num_cols - 1) do
          if {i, j} in path do
            "@"
          else
            data[{i, j}]
          end
        end

      [line, "\n"]
    end
    |> IO.puts()
  end
end
