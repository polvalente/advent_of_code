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

    {program, %{a: regA, b: regB, c: regC}}
  end

  @doc """
  iex> Day17.part1(Day17.test_input())
  "4,6,3,5,6,3,5,2,1,0"

  iex> Day17.part1(Day17.input())
  """
  def part1(input) do
    {program, registers} = parse(input)

    program =
      program
      |> String.trim_trailing()
      |> String.split(",", trim: true)
      |> Enum.with_index(fn <<row::utf8>>, idx -> {idx, row - ?0} end)
      |> Map.new()

    ip = 0
    max_valid_ip = Map.keys(program) |> Enum.max()
    {_, outs} = run_program(program, registers, ip, max_valid_ip)

    IO.iodata_to_binary(outs)
    |> String.trim_leading(",")
  end

  def run_program(program, reg, ip, max_valid_ip, outs \\ [])

  def run_program(_program, reg, ip, max_valid_ip, outs) when ip > max_valid_ip do
    {reg, outs}
  end

  def run_program(program, reg, ip, max_valid_ip, outs) do
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
        run_program(program, reg, ip + 2, max_valid_ip, outs)

      1 ->
        # bxl - bitwise xor of reg b and operand
        reg = %{reg | b: Bitwise.bxor(reg.b, operand)}
        run_program(program, reg, ip + 2, max_valid_ip, outs)

      2 ->
        # bst - reg B =  operand modulo 8
        reg = %{reg | b: rem(combo_operand, 8)}
        run_program(program, reg, ip + 2, max_valid_ip, outs)

      3 ->
        # jnz - nothing if A is 0
        # if A is not 0, set the instruction pointer to the literal operand

        if reg.a != 0 do
          run_program(program, reg, operand, max_valid_ip, outs)
        else
          run_program(program, reg, ip + 2, max_valid_ip, outs)
        end

      4 ->
        # bxc - bitwise xor of reg B and reg c, store in reg b
        reg = %{reg | b: Bitwise.bxor(reg.b, reg.c)}
        run_program(program, reg, ip + 2, max_valid_ip, outs)

      5 ->
        # out - output combo_operand mod 8
        out_str = rem(combo_operand, 8) + ?0
        run_program(program, reg, ip + 2, max_valid_ip, [outs, ?,, out_str])

      6 ->
        # bdv - same as adv, but stores in reg b
        numerator = reg.a
        reg = %{reg | b: Bitwise.bsr(numerator, combo_operand)}
        run_program(program, reg, ip + 2, max_valid_ip, outs)

      7 ->
        # cdv - same as cdv, but stores in reg c
        numerator = reg.a
        reg = %{reg | c: Bitwise.bsr(numerator, combo_operand)}
        run_program(program, reg, ip + 2, max_valid_ip, outs)
    end
  end
end
