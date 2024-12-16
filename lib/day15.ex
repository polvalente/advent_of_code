defmodule Day15 do
  use Day, day: 15

  @test_input """
  ##########
  #..O..O.O#
  #......O.#
  #.OO..O.O#
  #..O@..O.#
  #O#..O...#
  #O..O..O.#
  #.OO.O.OO#
  #....O...#
  ##########

  <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
  vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
  ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
  <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
  ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
  ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
  >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
  <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
  ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
  v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
  """

  def parse1(input) do
    [grid, path] = String.split(input, "\n\n", trim: true)

    grid = split_lines(grid)

    num_rows = length(grid)
    num_cols = String.length(hd(grid) |> String.trim())

    grid =
      grid
      |> Enum.with_index(fn line, i ->
        line
        |> String.to_charlist()
        |> Enum.with_index(fn
          ?#, j ->
            {{i, j}, :wall}

          ?O, j ->
            {{i, j}, :box}

          ?@, j ->
            [{{i, j}, :robot}, {:start, {i, j}}]

          ?., _j ->
            nil
        end)
      end)
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Map.new()

    {start, grid} = Map.pop!(grid, :start)

    moves =
      path
      |> String.replace("\n", "")
      |> String.to_charlist()
      |> Enum.map(fn
        ?< -> {0, -1}
        ?> -> {0, 1}
        ?^ -> {-1, 0}
        ?v -> {1, 0}
      end)

    {grid, moves, start, num_rows, num_cols}
  end

  @doc """
  iex> Day15.part1(Day15.test_input())
  10092

  iex> Day15.part1(Day15.input())
  1294459
  """
  def part1(input, debug? \\ false) do
    {grid, moves, start, num_rows, num_cols} = parse1(input)

    {grid, _} =
      Enum.reduce(moves, {grid, start}, fn move, {grid, pos} ->
        try do
          move_robot1(pos, move, grid, num_rows, num_cols)
        catch
          :move_failed ->
            {grid, pos}
        end
        |> tap(fn {grid, _pos} ->
          if debug? do
            print_grid(grid, num_rows, num_cols)
          end
        end)
      end)

    Enum.reduce(grid, 0, fn
      {{i, j}, :box}, acc ->
        acc + 100 * i + j

      _, acc ->
        acc
    end)
  end

  defp move_robot1({i, j}, {inc_i, inc_j}, grid, max_i, max_j) do
    target_pos = {i + inc_i, j + inc_j}

    if i + inc_i < 0 or i + inc_i >= max_i or j + inc_j < 0 or j + inc_j >= max_j do
      throw(:move_failed)
    else
      case Map.get(grid, target_pos) do
        :wall ->
          throw(:move_failed)

        :box ->
          {grid, _} = move_robot1(target_pos, {inc_i, inc_j}, grid, max_i, max_j)
          {value, grid} = Map.pop!(grid, {i, j})
          grid = Map.put(grid, target_pos, value)
          {grid, target_pos}

        nil ->
          {value, grid} = Map.pop!(grid, {i, j})
          grid = Map.put(grid, target_pos, value)
          {grid, target_pos}
      end
    end
  end

  defp print_grid(grid, num_rows, num_cols) do
    for i <- 0..(num_rows - 1) do
      for j <- 0..(num_cols - 1) do
        case Map.get(grid, {i, j}) do
          :wall -> "#"
          :box -> "O"
          :box_left -> "["
          :box_right -> "]"
          :robot -> [IO.ANSI.red(), "@", IO.ANSI.reset()]
          nil -> "."
        end
      end
      |> IO.puts()
    end
  end

  def parse2(input) do
    [grid, path] = String.split(input, "\n\n", trim: true)

    grid = split_lines(grid)

    grid =
      grid
      |> Enum.map(fn line ->
        line
        |> String.to_charlist()
        |> Enum.flat_map(fn
          ?# -> [?#, ?#]
          ?O -> [?[, ?]]
          ?@ -> [?@, ?.]
          ?. -> [?., ?.]
        end)
      end)
      |> Enum.with_index(fn line, i ->
        Enum.with_index(line, fn
          ?#, j ->
            {{i, j}, :wall}

          ?[, j ->
            {{i, j}, :box_left}

          ?], j ->
            {{i, j}, :box_right}

          ?@, j ->
            [{{i, j}, :robot}, {:start, {i, j}}]

          ?., _j ->
            nil
        end)
      end)
      |> List.flatten()
      |> Enum.reject(&is_nil/1)
      |> Map.new()

    {start, grid} = Map.pop!(grid, :start)
    {{num_rows, _}, _} = Enum.max_by(grid, fn {{i, _}, _} -> i end)
    {{_, num_cols}, _} = Enum.max_by(grid, fn {{_, j}, _} -> j end)

    num_rows = num_rows + 1
    num_cols = num_cols + 1

    moves =
      path
      |> String.replace("\n", "")
      |> String.to_charlist()
      |> Enum.map(fn
        ?< -> {0, -1}
        ?> -> {0, 1}
        ?^ -> {-1, 0}
        ?v -> {1, 0}
      end)

    {grid, moves, start, num_rows, num_cols}
  end

  @doc """
  iex> Day15.part2(Day15.test_input())
  9021

  iex> Day15.part2(Day15.input())
  1319212
  """
  def part2(input, debug? \\ false) do
    {grid, moves, start, num_rows, num_cols} = parse2(input)

    {grid, _} =
      Enum.reduce(moves, {grid, start}, fn move, {grid, pos} ->
        move_robot2(pos, move, grid)
        |> tap(fn {grid, _pos} ->
          if debug? do
            print_grid(grid, num_rows, num_cols)
          end
        end)
      end)

    Enum.reduce(grid, 0, fn
      {{i, j}, :box_left}, acc ->
        acc + 100 * i + j

      _, acc ->
        acc
    end)
  end

  defp can_move_robot?({i, j}, {inc_i, inc_j}, grid) do
    positions = get_box_positions({i, j}, {inc_i, inc_j}, grid)

    Enum.all?(positions, fn {i, j} ->
      next_pos_i = i + inc_i
      next_pos_j = j + inc_j

      case Map.get(grid, {next_pos_i, next_pos_j}) do
        nil ->
          true

        :wall ->
          false

        box when box in [:box_left, :box_right] ->
          if not can_move_robot?({next_pos_i, next_pos_j}, {inc_i, inc_j}, grid) do
            false
          else
            true
          end

        _ ->
          true
      end
    end)
  end

  defp do_move_robot({i, j}, {inc_i, inc_j}, grid) do
    positions = get_box_positions({i, j}, {inc_i, inc_j}, grid)

    grid =
      Enum.reduce(positions, grid, fn {i, j}, grid ->
        target = {i + inc_i, j + inc_j}
        dest = Map.get(grid, target)
        current = Map.get(grid, {i, j})

        case dest do
          nil ->
            grid
            |> Map.delete({i, j})
            |> Map.put(target, current)

          :wall ->
            raise "unexpected wall"

          box when box in [:box_left, :box_right] ->
            {grid, _} = do_move_robot(target, {inc_i, inc_j}, grid)

            grid
            |> Map.delete({i, j})
            |> Map.put(target, current)
        end
      end)

    {grid, {i + inc_i, j + inc_j}}
  end

  defp get_box_positions({i, j}, {inc_i, _inc_j}, grid) do
    case Map.get(grid, {i, j}) do
      :box_left when inc_i != 0 -> [{i, j}, {i, j + 1}]
      :box_right when inc_i != 0 -> [{i, j}, {i, j - 1}]
      _ -> [{i, j}]
    end
  end

  defp move_robot2(pos, move, grid) do
    if can_move_robot?(pos, move, grid) do
      do_move_robot(pos, move, grid)
    else
      {grid, pos}
    end
  end
end
