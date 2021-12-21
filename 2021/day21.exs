# Title: Day21

# ── Untitled ──

[p1start, p2start] =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\r\n", "\n"], trim: true)
  |> Enum.map(&(&1 |> String.split(": ") |> List.last() |> String.to_integer()))

defmodule D21 do
  def play(pos, inc) do
    sum = pos + rem(inc, 10)
    if sum > 10, do: sum - 10, else: sum
  end

  def solve1(p1start, p2start) do
    Stream.iterate(1, fn n -> rem(n, 100) + 1 end)
    |> Stream.chunk_every(3, 3, :discard)
    |> Stream.with_index(1)
    |> Enum.reduce_while(
      {{p1start, 0}, {p2start, 0}},
      fn
        {_, turn}, {{_, p1}, {_, p2}} when p1 >= 1000 ->
          {:halt, p2 * (turn - 1) * 3}

        {_, turn}, {{_, p1}, {_, p2}} when p2 >= 1000 ->
          {:halt, p1 * (turn - 1) * 3}

        {points, turn}, {{p1pos, p1score}, {p2pos, p2score}} ->
          {:cont,
           case rem(turn, 2) do
             1 ->
               pos = play(p1pos, Enum.sum(points))
               {{pos, p1score + pos}, {p2pos, p2score}}

             0 ->
               pos = play(p2pos, Enum.sum(points))
               {{p1pos, p1score}, {pos, p2score + pos}}
           end}
      end
    )
  end

  @inc (for u1 <- 1..3, u2 <- 1..3, u3 <- 1..3 do
          Enum.sum([u1, u2, u3])
        end)
       |> Enum.frequencies()
  def split({state, turn}) do
    if rem(turn, 2) == 1 do
      for {{p1, s1, p2, s2}, c1} <- state, s2 < 21, {inc, c2} <- @inc do
        p1 = play(p1, inc)
        {{p1, s1 + p1, p2, s2}, c1 * c2}
      end
    else
      for {{p1, s1, p2, s2}, c1} <- state, s1 < 21, {inc, c2} <- @inc do
        p2 = play(p2, inc)
        {{p1, s1, p2, s2 + p2}, c1 * c2}
      end
    end
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Enum.map(fn {k, v} -> {k, Enum.sum(v)} end)
    |> then(&{&1, turn + 1})
  end

  def solve2(p1start, p2start) do
    Stream.iterate({[{{p1start, 0, p2start, 0}, 1}], 1}, &split/1)
    |> Stream.map(&elem(&1, 0))
    |> Enum.take_while(fn
      [] -> false
      _ -> true
    end)
    |> Enum.reduce({0, 0}, fn state, {s1, s2} ->
      {s1 +
         (state
          |> Enum.filter(fn {{_, s, _, _}, _} -> s >= 21 end)
          |> Enum.map(fn {_, c} -> c end)
          |> Enum.sum()),
       s2 +
         (state
          |> Enum.filter(fn {{_, _, _, s}, _} -> s >= 21 end)
          |> Enum.map(fn {_, c} -> c end)
          |> Enum.sum())}
    end)
    |> then(fn {left, right} -> max(left, right) end)
  end
end

# ── P1 ──

D21.solve1(p1start, p2start)

# ── P2 ──

D21.solve2(p1start, p2start)
