defmodule Day3 do
  use Day, day: 3

  defmodule Part1 do
    import NimbleParsec

    mul =
      ignore(string("mul("))
      |> integer(min: 1)
      |> ignore(string(","))
      |> integer(min: 1)
      |> ignore(string(")"))
      |> tag(&Kernel.*/2)

    instructions = eventually(mul)

    defparsec :text, repeat(instructions)

    def run(text) do
      {:ok, instructions, _, _, _, _} = text(text)
      for {instruction, args} <- instructions do
        apply(instruction, args)
      end
      |> Enum.sum()
    end
  end

  defmodule Part2 do
    import NimbleParsec

    mul =
      ignore(string("mul("))
      |> integer(min: 1)
      |> ignore(string(","))
      |> integer(min: 1)
      |> ignore(string(")"))
      |> tag(&Kernel.*/2)

    do_instruction = ignore(string("do()")) |> tag(:do)
    dont_instruction = ignore(string("don't()")) |> tag(:dont)

    instructions = eventually(choice([mul, do_instruction, dont_instruction]))

    defparsec(:text, repeat(instructions))

    def run(text) do
      {:ok, instructions, _, _, _, _} = text(text)

      {keep_instructions, _} =
        Enum.map_reduce(instructions, true, fn
          {:do, []}, _ -> {{false, :do}, true}
          {:dont, []}, _ -> {{false, :dont}, false}
          instruction, acc -> {{acc, instruction}, acc}
        end)

      for {true, {instruction, args}} <- keep_instructions do
        apply(instruction, args)
      end
      |> Enum.sum()
    end
  end

  @test_input """
  xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
  """

  @doc """
  ## Examples

      iex> Day3.part1(Day3.test_input())
      161

      iex> Day3.part1(Day3.input())
      155955228
  """
  def part1(input) do
    Day3.Part1.run(input)
  end

  @doc """
  ## Examples

      iex> Day3.part2(Day3.test_input())
      48

      iex> Day3.part2(Day3.input())
      100189366
  """
  def part2(input) do
    Day3.Part2.run(input)
  end
end
