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
  def calc(from, data, seen, exception, path) do
    next = data[from]

    seen =
      if match?(<<c::8, _::binary>> when c in ?a..?z, from) do
        [from | seen]
      else
        seen
      end

    next
    |> Kernel.--(seen)
    |> Enum.each(fn
      "end" ->
        Agent.update(P2, &MapSet.put(&1, [from | path]))

      next ->
        calc(next, data, seen, exception, [from | path])

        if is_nil(exception) and match?([^from | _], seen) do
          [^from | seen] = seen
          calc(next, data, seen, from, [from | path])
        end
    end)
  end
end

Agent.start(fn -> MapSet.new() end, name: P2)
P2.calc("start", data, [], nil, [])
IO.inspect(Agent.get(P2, &MapSet.size/1))
Agent.stop(P2)
