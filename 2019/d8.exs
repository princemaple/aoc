defmodule M do
  def x(t, w, h) do
    counts =
      Enum.map(layers(t, w, h), fn layer ->
        Enum.reduce(layer, %{}, fn char, acc ->
          Map.update(acc, char, 1, &(&1 + 1))
        end)
      end)

    layer = Enum.min_by(counts, & &1["0"])
    layer["1"] * layer["2"]
  end

  def y(t, w, h) do
    layers(t, w, h)
    |> transpose
    |> Enum.map(fn l ->
      Enum.find(l, & &1 != "2")
    end)
    |> Enum.chunk_every(w)
    |> Enum.map(fn l ->
      "<tr>\n" <>
      (Enum.map(l, fn c ->
        case c do
          "1" ->
            ~s|<td style="background: white;"></td>|
          "0" ->
            ~s|<td style="background: black;"></td>|
        end
      end)
      |> Enum.join("\n"))
      <> "</tr>"
    end)
    |> final
  end

  defp final(l) do
    IO.puts "<table>"
    Enum.each(l, &IO.puts/1)
    IO.puts "</table>"
  end

  def layers(t, w, h) do
    size = w * h

    for << <<l::binary-size(size)>> <- String.trim(t)>> do
      String.graphemes(l)
    end
  end

  def transpose([]), do: []
  def transpose([[]|_]), do: []
  def transpose(a) do
    [Enum.map(a, &hd/1) | transpose(Enum.map(a, &tl/1))]
  end
end
