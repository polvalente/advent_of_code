defmodule Day4 do
  use Day, day: 4

  @test_input """
  MMMSXXMASM
  MSAMXMSMSA
  AMXSXMAAMM
  MSAMASMSMX
  XMASAMXAMM
  XXAMMXXAMA
  SMSMSASXSS
  SAXAMASAAA
  MAMMMXMMMM
  MXMXAXMASX
  """

  def parse(text) do
    text
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
  end

  def search_rows(matrix, pattern) do
    matrix
    |> Enum.map(fn row ->
      Regex.scan(Regex.compile!(pattern), Enum.join(row) <> Enum.join(Enum.reverse(row)))
    end)
    |> List.flatten()
    |> Enum.count(& &1)
  end

  def search_cols(matrix, pattern) do
    Enum.zip_with(matrix, & &1)
    |> search_rows(pattern)
  end

  def search_diagonals(matrix, pattern) do
    matrix_map =
      matrix
      |> Enum.with_index(fn row, row_num ->
        Enum.with_index(row, fn item, col_num ->
          {{row_num, col_num}, item}
        end)
      end)
      |> List.flatten()
      |> Map.new()

    num_cols = length(hd(matrix))
    num_rows = length(matrix)

    len_pattern = byte_size(pattern)

    for i <- 0..(num_rows - 1), j <- 0..(num_cols - 1) do
      down_right =
        for c <- 0..(len_pattern - 1), into: "" do
          matrix_map[{i + c, j + c}] || ""
        end

      down_left =
        for c <- 0..(len_pattern - 1), into: "" do
          matrix_map[{i + c, j - c}] || ""
        end

      up_right =
        for c <- 0..(len_pattern - 1), into: "" do
          matrix_map[{i - c, j + c}] || ""
        end

      up_left =
        for c <- 0..(len_pattern - 1), into: "" do
          matrix_map[{i - c, j - c}] || ""
        end

      [down_right == pattern, down_left == pattern, up_right == pattern, up_left == pattern]
    end
    |> List.flatten()
    |> Enum.count(& &1)
  end

  @doc """
  ## Examples

      iex> Day4.part1(Day4.test_input())
      18

      iex> Day4.part1(Day4.input())
      2434
  """
  def part1(input) do
    t = parse(input)

    search_rows(t, "XMAS") + search_cols(t, "XMAS") + search_diagonals(t, "XMAS")
  end

  def match_3x3([
        [m, _, m],
        [_, "A", _],
        [s, _, s]
      ])
      when (m == "M" and s == "S") or (m == "S" and s == "M"),
      do: true

  def match_3x3([
        [m, _, s],
        [_, "A", _],
        [m, _, s]
      ])
      when (m == "M" and s == "S") or (m == "S" and s == "M"),
      do: true

  def match_3x3(_), do: false

  @doc """
  ## Examples

      iex> Day4.part2(Day4.test_input())
      9

      iex> Day4.part2(Day4.input())
      1835
  """
  def part2(input) do
    matrix = parse(input)
    num_rows = length(matrix)
    num_cols = length(matrix)

    for i <- 0..(num_rows - 3), j <- 0..(num_cols - 3), reduce: 0 do
      acc ->
        Enum.drop(matrix, i)
        |> Enum.take(3)
        |> Enum.map(fn row ->
          Enum.drop(row, j)
          |> Enum.take(3)
        end)
        |> match_3x3()
        |> if do
          acc + 1
        else
          acc
        end
    end
  end
end
