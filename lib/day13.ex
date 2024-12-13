defmodule Day13 do
  use Day, day: 13

  @test_input """
  Button A: X+94, Y+34
  Button B: X+22, Y+67
  Prize: X=8400, Y=5400

  Button A: X+26, Y+66
  Button B: X+67, Y+21
  Prize: X=12748, Y=12176

  Button A: X+17, Y+86
  Button B: X+84, Y+37
  Prize: X=7870, Y=6450

  Button A: X+69, Y+23
  Button B: X+27, Y+71
  Prize: X=18641, Y=10279
  """

  def parse(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(fn chunk ->
      [line1, line2, line3] = String.split(chunk, "\n", trim: true)

      "Button A: X+" <> tail = line1
      [x_inc_str, y_inc_str] = String.split(tail, ", Y+", trim: true, parts: 2)

      a_x_inc = String.to_integer(x_inc_str)
      a_y_inc = String.to_integer(y_inc_str)

      "Button B: X+" <> tail = line2
      [x_inc_str, y_inc_str] = String.split(tail, ", Y+", trim: true, parts: 2)

      b_x_inc = String.to_integer(x_inc_str)
      b_y_inc = String.to_integer(y_inc_str)

      "Prize: X=" <> tail = line3
      [x_str, y_str] = String.split(tail, ", Y=", trim: true, parts: 2)

      prize_x = String.to_integer(x_str)
      prize_y = String.to_integer(y_str)

      %{a: %{x: a_x_inc, y: a_y_inc}, b: %{x: b_x_inc, y: b_y_inc}, prize: %{x: prize_x, y: prize_y}}
    end)
  end

  def input0 do
    """
    Button A: X+94, Y+34
    Button B: X+22, Y+67
    Prize: X=8400, Y=5400
    """
  end

  @doc """
  iex> Day13.part1(Day13.test_input())
  480

  iex> Day13.part1(Day13.input())
  37686
  """
  def part1(input) do
    # this is dumb and slow, but it works and is too funny to change
    button_cost = Nx.tensor([3, 1], backend: EXLA.Backend)
    for %{a: a, b: b, prize: prize} <- parse(input) do
      a = Nx.tensor([
        [a.x, b.x],
        [a.y, b.y]
      ], backend: EXLA.Backend)

      prize = Nx.tensor([prize.x, prize.y], backend: EXLA.Backend)


      {init_n, _} = Nx.Random.uniform(Nx.Random.key(System.system_time()) |> Nx.backend_copy(EXLA.Backend), shape: {2})
      {init_fn, update_fn} = Polaris.Optimizers.adam(learning_rate: 0.1)
      init_optimizer_state = init_fn.(init_n)

      {_state, n, _loss} =
        0..100_000
        |> Enum.reduce_while({init_optimizer_state, init_n, 0}, fn _, {optimizer_state, n, prev_loss} ->
          {new_n, optimizer_state, loss} = Nx.Defn.jit_apply(&update/4, [{a, prize, button_cost}, optimizer_state, n, update_fn], compiler: EXLA)

          if Nx.to_number(Nx.abs(Nx.subtract(loss, prev_loss))) < 0.001 do
            {:halt, {optimizer_state, new_n, loss}}
          else
            {:cont, {optimizer_state, new_n, loss}}
          end
        end)

      n_int = Nx.round(n) |> Nx.as_type(:s32)

      abs_diff = Nx.dot(a, n_int) |> Nx.subtract(prize) |>  Nx.abs() |> Nx.all_close(Nx.tensor(0)) |> Nx.to_number()

      if abs_diff == 1 do
        Nx.dot(n_int, button_cost) |> Nx.to_number()
      else
        0
      end
    end
    |> Enum.sum()
  end

  import Nx.Defn

  defn loss_function(a, n, prize, button_cost) do
    Nx.LinAlg.norm(Nx.dot(a, n) - prize) + Nx.dot(n, button_cost)
  end

  defn update({a, prize, button_cost}, optimizer_state, n, update_fn) do
    {loss, g} = value_and_grad(n, &loss_function(a, &1, prize, button_cost))

    {scaled_updates, new_optimizer_state} = update_fn.(g, optimizer_state, n)

    {Polaris.Updates.apply_updates(n, scaled_updates), new_optimizer_state, loss}
  end

  @doc """
  iex> Day13.part2(Day13.test_input())
  875318608908

  iex> Day13.part2(Day13.input())
  77204516023437
  """
  def part2(input) do
    offset = 10000000000000
    for %{a: a, b: b, prize: prize} <- parse(input), reduce: 0 do
      cost ->

      t =
        Nx.u64([
          [a.x, b.x],
          [a.y, b.y]
        ])

      p = Nx.u64([[prize.x + offset], [prize.y + offset]])

      # nb via Cramer's rule
      nb =
        Nx.quotient(
          integer_det(Nx.put_slice(t, [0, 1], p)),
          integer_det(t)
        )
        |> Nx.to_number()

      # na via substitution in the first equation
      na = div(prize.x + offset - nb * b.x, a.x)

      actual_p = Nx.dot(t, Nx.u64([[na], [nb]]))

      if  actual_p == p do
        cost + 3 * na + nb
      else
        cost
      end
    end
  end

  defn integer_det(t) do
    t = t |> Nx.tile([1, 2])
    main_diag = Nx.take_diagonal(t)
    sub_diag = Nx.take_diagonal(t, offset: 1)

    Nx.product(main_diag) - Nx.product(sub_diag)
  end
end
