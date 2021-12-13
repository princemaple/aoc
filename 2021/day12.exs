# Title: Day12

# ── Untitled ──

data =
  "input"
  |> IO.getn(1_000_000)
  |> String.trim()
  |> String.split(["\n", "\r\n"], trim: true)
  |> Enum.map(&String.split(&1, "-"))

data =
  for [from, to] <- data do
    [{from, to}, {to, from}]
  end
  |> List.flatten()
  |> Enum.reject(fn {from, to} -> from == "end" or to == "start" end)
  |> Enum.group_by(fn {f, _t} -> f end, fn {_f, t} -> t end)

defmodule P1 do
  def calc(from, data, seen) do
    next = data[from]

    seen =
      if match?(<<c::8, _::binary>> when c in ?a..?z, from) do
        [from | seen]
      else
        seen
      end

    next
    |> Kernel.--(seen)
    |> Enum.reduce(0, fn
      "end", sum ->
        sum + 1

      next, sum ->
        sum + calc(next, data, seen)
    end)
  end
end

P1.calc("start", data, [])

defmodule P2 do
  def calc(from, data, seen, exception) do
    seen =
      if match?(<<c::8, _::binary>> when c in ?a..?z, from) do
        [from | seen]
      else
        seen
      end

    exception = exception && Enum.count_until(seen, &(&1 == from), 2) <= 1
    next = data[from] -- if(exception, do: [], else: seen)

    Enum.reduce(next, 0, fn
      "end", sum ->
        sum + 1

      next, sum ->
        sum + calc(next, data, seen, exception)
    end)
  end
end

P2.calc("start", data, [], true)
