defmodule Day5 do
  use Day, day: 5

  @test_input """
  47|53
  97|13
  97|61
  97|47
  75|29
  61|13
  75|53
  29|13
  97|29
  53|29
  61|53
  97|53
  61|29
  47|13
  75|47
  97|75
  47|61
  75|61
  47|29
  75|13
  53|13

  75,47,61,53,29
  97,61,53,29,13
  75,29,13
  75,97,47,61,53
  61,13,29
  97,13,75,29,47
  """

  @doc """
      iex> Day5.part1(Day5.test_input())
      143

      iex> Day5.part1(Day5.input())
      5651
  """
  def part1(input) do
    [requirements, steps] = String.split(input, "\n\n", trim: true)

    before_requirements =
      requirements
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "|", trim: true))
      |> Enum.group_by(fn [page, _before_than] -> page end, fn [_page, before_than] ->
        before_than
      end)

    updates = String.split(steps, "\n", trim: true)

    for steps <- updates do
      steps = String.split(steps, ",", trim: true)

      if is_ordered?(steps, before_requirements) do
        len = length(steps)

        Enum.fetch!(steps, div(len, 2))
        |> String.to_integer()
      else
        0
      end
    end
    |> Enum.sum()
  end

  defp is_ordered?(steps, before_requirements) do
    Enum.reduce_while(0..(length(steps) - 2), true, fn idx, _ ->
      {_before_than, [current | after_than]} = Enum.split(steps, idx)

      before_reqs = before_requirements[current]

      all_before =
        before_reqs &&
          Enum.all?(after_than, fn b ->
            b in before_reqs
          end)

      if all_before do
        {:cont, true}
      else
        {:halt, false}
      end
    end)
  end

  @doc """
      iex> Day5.part2(Day5.test_input())
      123

      iex> Day5.part2(Day5.input())
      4743
  """
  def part2(input) do
    [requirements, steps] = String.split(input, "\n\n", trim: true)

    rules =
      requirements
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "|", trim: true))

    before_requirements =
      Enum.group_by(rules, fn [page, _before_than] -> page end, fn [_page, before_than] ->
        before_than
      end)

    updates = String.split(steps, "\n", trim: true)

    for steps <- updates do
      steps = String.split(steps, ",", trim: true)

      if is_ordered?(steps, before_requirements) do
        nil
      else
        steps
      end
    end
    |> Enum.filter(& &1)
    |> Enum.map(fn l ->
      reordered = reorder(l, rules, before_requirements)

      Enum.map(l, &{&1, length(before_requirements[&1] || [])})
      |> Enum.sort_by(fn {_k, v} -> v end, :desc)
      |> Enum.map(fn {k, _} -> k end)

      Enum.fetch!(reordered, div(length(reordered), 2))
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  defp reorder(steps, rules, requirements, done? \\ false)

  defp reorder(steps, _rules, _requirements, true), do: steps

  defp reorder(list, rules, requirements, false) do
    reordered =
      Enum.reduce(rules, list, fn [x, y], list ->
        x_idx = Enum.find_index(list, &(&1 == x))
        y_idx = Enum.find_index(list, &(&1 == y))

        if x_idx && y_idx && y_idx < x_idx do
          list
          |> List.replace_at(x_idx, Enum.fetch!(list, y_idx))
          |> List.replace_at(y_idx, Enum.fetch!(list, x_idx))
        else
          list
        end
      end)

    reorder(reordered, rules, requirements, is_ordered?(reordered, requirements))
  end
end
