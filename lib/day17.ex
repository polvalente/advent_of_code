defmodule Day17 do
  use Day, day: 17

  @test_input """
  Register A: 729
  Register B: 0
  Register C: 0

  Program: 0,1,5,4,3,0
  """

  def parse(input) do
    [registers, program] = String.split(input, "\n\n", trim: true)

    ["Register A: " <> regA, "Register B: " <> regB, "Register C: " <> regC] =
      String.split(registers, "\n", trim: true)

    regA = String.to_integer(regA)
    regB = String.to_integer(regB)
    regC = String.to_integer(regC)

    "Program: " <> program = program

    program =
      program
      |> String.trim_trailing()
      |> String.split(",", trim: true)
      |> Enum.with_index(fn <<row::utf8>>, idx -> {idx, row - ?0} end)
      |> Map.new()

    {program, %{a: regA, b: regB, c: regC}}
  end

  @doc """
  iex> Day17.part1(Day17.test_input())
  "4,6,3,5,6,3,5,2,1,0"

  iex> Day17.part1(Day17.input())
  """
  def part1(input) do
    {program, registers} = parse(input)

    ip = 0
    max_valid_ip = Map.keys(program) |> Enum.max()
    {_, outs} = run_program(program, registers, ip, max_valid_ip)

    IO.iodata_to_binary(outs)
    |> String.trim_leading(",")
  end

  def run_program(program, reg, ip, max_valid_ip, outs \\ [], expected_outs \\ nil)

  def run_program(_program, reg, ip, max_valid_ip, outs, _expected_outs) when ip > max_valid_ip do
    {reg, outs}
  end

  def run_program(program, reg, ip, max_valid_ip, outs, expected_outs) do
    instruction = program[ip]
    operand = program[ip + 1]

    combo_operand =
      case operand do
        0 ->
          0

        1 ->
          1

        2 ->
          2

        3 ->
          3

        4 ->
          reg.a

        5 ->
          reg.b

        6 ->
          reg.c

        7 ->
          # reserved operand
          nil
      end

    case instruction do
      0 ->
        # adv - division
        numerator = reg.a
        reg = %{reg | a: Bitwise.bsr(numerator, combo_operand)}
        run_program(program, reg, ip + 2, max_valid_ip, outs, expected_outs)

      1 ->
        # bxl - bitwise xor of reg b and operand
        reg = %{reg | b: Bitwise.bxor(reg.b, operand)}
        run_program(program, reg, ip + 2, max_valid_ip, outs, expected_outs)

      2 ->
        # bst - reg B =  operand modulo 8
        reg = %{reg | b: rem(combo_operand, 8)}
        run_program(program, reg, ip + 2, max_valid_ip, outs, expected_outs)

      3 ->
        # jnz - nothing if A is 0
        # if A is not 0, set the instruction pointer to the literal operand

        if reg.a != 0 do
          run_program(program, reg, operand, max_valid_ip, outs, expected_outs)
        else
          run_program(program, reg, ip + 2, max_valid_ip, outs, expected_outs)
        end

      4 ->
        # bxc - bitwise xor of reg B and reg c, store in reg b
        reg = %{reg | b: Bitwise.bxor(reg.b, reg.c)}
        run_program(program, reg, ip + 2, max_valid_ip, outs, expected_outs)

      5 ->
        # out - output combo_operand mod 8
        out_str = rem(combo_operand, 8) + ?0

        expected_outs =
          if expected_outs do
            if expected_outs == [] do
              throw(:skip)
            end

            [expected | expected_outs] = expected_outs

            if out_str != expected + ?0 do
              throw(:skip)
            end

            expected_outs
          end

        run_program(program, reg, ip + 2, max_valid_ip, [outs, ?,, out_str], expected_outs)

      6 ->
        # bdv - same as adv, but stores in reg b
        numerator = reg.a
        reg = %{reg | b: Bitwise.bsr(numerator, combo_operand)}
        run_program(program, reg, ip + 2, max_valid_ip, outs, expected_outs)

      7 ->
        # cdv - same as cdv, but stores in reg c
        numerator = reg.a
        reg = %{reg | c: Bitwise.bsr(numerator, combo_operand)}
        run_program(program, reg, ip + 2, max_valid_ip, outs, expected_outs)
    end
  end

  def test_input2 do
    """
    Register A: 2024
    Register B: 0
    Register C: 0

    Program: 0,3,5,4,3,0
    """
  end

  @doc """
  iex> Day17.part2(Day17.test_input2())
  117440

  iex> Day17.part2(Day17.input())
  236555997372013
  """
  def part2(input) do
    {program, _regs} = parse(input)
    max_valid_ip = Map.keys(program) |> Enum.max()

    expected_out = program |> Enum.sort() |> Enum.map(fn {_, v} -> v + ?0 end)

    calculate_a(program, max_valid_ip, max_valid_ip, [0], expected_out)
  end

  defp calculate_a(program, max_valid_ip, idx, possible_as, expected_out) do
    possible_as =
      for guess <- possible_as, a <- (guess * 8)..(guess * 8 + 7), reduce: [] do
        acc ->
          {_, outs} = run_program(program, %{a: a, b: 0, c: 0}, 0, max_valid_ip)

          outs = Enum.reject(List.flatten(outs), &(&1 == ?,))

          if outs == Enum.slice(expected_out, idx..max_valid_ip) do
            [a | acc]
          else
            acc
          end
      end

    if idx == 0 do
      Enum.min(possible_as)
    else
      calculate_a(program, max_valid_ip, idx - 1, possible_as, expected_out)
    end
  end
end
