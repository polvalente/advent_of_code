defmodule AOC2024.Day23 do
  use Day, day: 23
  use Memoize

  @test_input """
  kh-tc
  qp-kh
  de-cg
  ka-co
  yn-aq
  qp-ub
  cg-tb
  vc-aq
  tb-ka
  wh-tc
  yn-cg
  kh-ub
  ta-co
  de-co
  tc-td
  tb-wq
  wh-td
  ta-ka
  td-qp
  aq-cg
  wq-ub
  ub-vc
  de-ta
  wq-aq
  wq-vc
  wh-yn
  ka-de
  kh-ta
  co-tc
  wh-qp
  tb-vc
  td-yn
  """

  def parse(input) do
    input
    |> split_lines()
    |> Enum.map(fn line ->
      [left, right] = String.split(line, "-", parts: 2)
      {left, String.trim(right)}
    end)
    |> Enum.reduce(%{}, fn {left, right}, acc ->
      current_left = acc[left] || MapSet.new()
      current_right = acc[right] || MapSet.new()

      acc
      |> Map.put(left, MapSet.put(current_left, right))
      |> Map.put(right, MapSet.put(current_right, left))
    end)
  end

  @doc """
  iex> AOC2024.Day23.part1(AOC2024.Day23.test_input())
  7

  iex> AOC2024.Day23.part1(AOC2024.Day23.input())
  1215
  """
  def part1(input) do
    network_map = parse(input)

    for {c0, connections} <- network_map,
        c1 <- connections,
        c2 <- connections,
        c1 != c2 and c1 != c0 and c2 != c0 and
          (String.starts_with?(c1, "t") or
             String.starts_with?(c2, "t") or String.starts_with?(c0, "t")),
        reduce: {0, MapSet.new()} do
      {acc, seen} ->
        set = Enum.sort([c0, c1, c2])

        if MapSet.member?(network_map[c1], c2) and not MapSet.member?(seen, set) do
          {acc + 1, MapSet.put(seen, set)}
        else
          {acc, seen}
        end
    end
    |> elem(0)
  end

  @doc """
  iex> AOC2024.Day23.part2(AOC2024.Day23.test_input())
  "co,de,ka,ta"

  iex> AOC2024.Day23.part2(AOC2024.Day23.input())
  "bm,by,dv,ep,ia,ja,jb,ks,lv,ol,oy,uz,yt"
  """
  def part2(input) do
    network_map = parse(input)
    graph = Graph.new(type: :undirected)

    graph =
      Enum.reduce(network_map, graph, fn {source, sinks}, graph ->
        g = Graph.add_vertex(graph, source)

        for sink <- sinks, reduce: g do
          g ->
            g
            |> Graph.add_vertex(sink)
            |> Graph.add_edge(source, sink)
        end
      end)

    Graph.cliques(graph)
    |> Enum.max_by(&length/1)
    |> Enum.sort()
    |> Enum.join(",")
  end
end
