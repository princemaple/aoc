defmodule M do
  def x(t) do
    t
    |> clean
    |> Enum.reduce(%{}, fn [c, o], m ->
      Map.update(m, c, [o], &[o | &1])
    end)
    |> IO.inspect
    |> calcx("COM")
    |> List.flatten
    |> Enum.sum
  end

  defp calcx(m, from, depth \\ 0) do
    case m[from] do
      nil -> depth
      list -> [depth | Enum.map(list, &calcx(m, &1, depth + 1))]
    end
  end

  def y(t) do
    t
    |> clean
    |> Enum.reduce(%{}, fn [c, o], m -> Map.put(m, o, c) end)
    |> calcy
  end

  defp calcy(m) do
    {["YOU" | p_you], s_you} = path(m, "YOU")
    {["SAN" | p_san], s_san} = path(m, "SAN")

    s = MapSet.intersection(s_you, s_san)

    i_you = Enum.find_index(p_you, &MapSet.member?(s, &1))
    i_san = Enum.find_index(p_san, &MapSet.member?(s, &1))

    i_you + i_san
  end

  defp path(m, from, p \\ [], s \\ MapSet.new)

  defp path(_, nil, p, s) do {Enum.reverse(p), s} end

  defp path(m, from, p, s) do
    path(m, m[from], [from | p], MapSet.put(s, from))
  end

  defp clean(t) do
    t
    |> String.trim
    |> String.split
    |> Enum.map(&String.split(&1, ")"))
  end
end
