defmodule AOC2024.Day24 do
  use Day, day: 24
  use Memoize

  @test_input """
  x00: 1
  x01: 1
  x02: 1
  y00: 0
  y01: 1
  y02: 0

  x00 AND y00 -> z00
  x01 XOR y01 -> z01
  x02 OR y02 -> z02
  """

  @test_input2 """
  x00: 1
  x01: 0
  x02: 1
  x03: 1
  x04: 0
  y00: 1
  y01: 1
  y02: 1
  y03: 1
  y04: 1

  ntg XOR fgs -> mjb
  y02 OR x01 -> tnw
  kwq OR kpj -> z05
  x00 OR x03 -> fst
  tgd XOR rvg -> z01
  vdt OR tnw -> bfw
  bfw AND frj -> z10
  ffh OR nrd -> bqk
  y00 AND y03 -> djm
  y03 OR y00 -> psh
  bqk OR frj -> z08
  tnw OR fst -> frj
  gnj AND tgd -> z11
  bfw XOR mjb -> z00
  x03 OR x00 -> vdt
  gnj AND wpb -> z02
  x04 AND y00 -> kjc
  djm OR pbm -> qhw
  nrd AND vdt -> hwm
  kjc AND fst -> rvg
  y04 OR y02 -> fgs
  y01 AND x02 -> pbm
  ntg OR kjc -> kwq
  psh XOR fgs -> tgd
  qhw XOR tgd -> z09
  pbm OR djm -> kpj
  x03 XOR y03 -> ffh
  x00 XOR y04 -> ntg
  bfw OR bqk -> z06
  nrd XOR fgs -> wpb
  frj XOR qhw -> z04
  bqk OR frj -> z07
  y03 OR x01 -> nrd
  hwm AND bqk -> z03
  tgd XOR rvg -> z12
  tnw OR pbm -> gnj
  """

  def test_input2, do: @test_input2

  def parse(input) do
    [vars, rules] = String.split(input, "\n\n", trim: true, parts: 2)

    vars =
      vars
      |> split_lines()
      |> Enum.map(fn line ->
        [var, value] = String.split(line, ": ", trim: true, parts: 2)
        {var, String.to_integer(value)}
      end)
      |> Map.new()

    rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [left, op, right, out] = String.split(line, [" ", "->"], trim: true)

        op =
          case op do
            "AND" -> &Bitwise.band/2
            "OR" -> &Bitwise.bor/2
            "XOR" -> &Bitwise.bxor/2
          end

        {out, {op, left, right}}
      end)
      |> Map.new()

    {vars, rules}
  end

  @doc """
  iex> AOC2024.Day24.part1(AOC2024.Day24.test_input())
  4

  iex> AOC2024.Day24.part1(AOC2024.Day24.test_input2())
  2024

  iex> AOC2024.Day24.part1(AOC2024.Day24.input())
  51410244478064
  """
  def part1(input) do
    {vars, rules} = parse(input)

    vars = apply_rules(vars, rules)

    get_num(vars, "z")
  end

  def get_num(vars, prefix) do
    vars
    |> Enum.filter(fn {k, _v} -> String.starts_with?(k, prefix) end)
    |> Enum.sort_by(fn {k, _} -> k end, :desc)
    |> Enum.map(fn {_, v} -> v end)
    |> Integer.undigits(2)
  end

  def apply_rules(vars, rules) do
    {vars, has_updated} =
      Enum.reduce(rules, {vars, false}, fn {out, {op, left, right}}, {vars, has_updated} ->
        apply_rule(has_updated, vars, out, {op, left, right})
      end)

    if has_updated do
      apply_rules(vars, rules)
    else
      vars
    end
  end

  defmemo apply_rule(has_updated, vars, out, {op, left, right}) do
    case vars do
      %{^out => _} ->
        {vars, has_updated}

      %{^left => left_value, ^right => right_value} ->
        {Map.put(vars, out, op.(left_value, right_value)), true}

      _ ->
        {vars, has_updated}
    end
  end

  def part2_manual(input) do
    # this was done iteratively by hand.
    # the loop below checks each bit so that I could more easily pinpoint the problems.
    # I first went through the carry chain to find the first 2 swaps.
    # Remaining swaps were indicated by the loop.
    test_range = 0..44
    swaps = [{"nhn", "z21"}, {"gst", "z33"}, {"z12", "vdc"}, {"khg", "tvb"}]
    {vars, rules} = parse(input)

    rules =
      Enum.reduce(swaps, rules, fn {left, right}, rules ->
        rules
        |> Map.put(right, rules[left])
        |> Map.put(left, rules[right])
      end)

    # Test each bit position
    Enum.each(test_range, fn i ->
      # Set x and y bits for this test
      vars = set_test_bits(vars, i)
      result = apply_rules(vars, rules)

      # Get the expected result for this bit position
      actual_i = Map.get(result, "z#{String.pad_leading("#{i}", 2, "0")}")

      # Print positions where results don't match
      if actual_i != 0 do
        IO.puts("Mismatch at bit #{i}:")
        IO.puts("  Expected: #{0}")
        IO.puts("  Got: #{actual_i}")

        # throw({:mismatch, result})
      end
    end)
  end

  @doc """
  iex> AOC2024.Day24.part2(AOC2024.Day24.input())
  "gst,khg,nhn,tvb,vdc,z12,z21,z33"
  """
  def part2(input) do
    swaps = [{"nhn", "z21"}, {"gst", "z33"}, {"z12", "vdc"}, {"khg", "tvb"}]
    {vars, rules} = parse(input)

    rules =
      Enum.reduce(swaps, rules, fn {left, right}, rules ->
        rules
        |> Map.put(right, rules[left])
        |> Map.put(left, rules[right])
      end)

    result = apply_rules(vars, rules)

    z = get_num(result, "z")
    x = get_num(vars, "x")
    y = get_num(vars, "y")

    if z != x + y do
      raise "incorrect swaps"
    end

    swaps
    |> Enum.flat_map(fn {l, r} -> [l, r] end)
    |> Enum.sort()
    |> Enum.join(",")
  end

  defp set_test_bits(vars, i) do
    # Set all bits to 0 except position i for both x and y
    vars =
      Enum.reduce(0..44, vars, fn j, acc ->
        x_val = if j == i, do: 1, else: 0
        y_val = if j == i, do: 1, else: 0

        acc
        |> Map.put("x#{String.pad_leading("#{j}", 2, "0")}", x_val)
        |> Map.put("y#{String.pad_leading("#{j}", 2, "0")}", y_val)
      end)

    vars
  end
end
