defmodule AdventOfCode24.Day2 do
  def get_puzzle() do
    Req.get("https://adventofcode.com/2024/day/2/input")
    |> IO.inspect()
  end

  def puzzle() do
    """
    7 6 4 2 1
    1 2 7 8 9
    9 7 6 2 1
    1 3 2 4 5
    8 6 4 4 1
    1 3 6 7 9
    """
  end

  def part_1() do
    puzzle()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn e -> Enum.map(e, &String.to_integer/1) end)
    |> Enum.map(fn e -> is_safe(e) end)
    |> Enum.sum()
  end

  def is_safe([first, second | _] = list) do
    chunk = Enum.chunk_every(list, 2, 1, :discard)

    in_proper_series =
      if second > first do
        Enum.all?(chunk, fn [a, b] -> a < b end)
      else
        Enum.all?(chunk, fn [a, b] -> a > b end)
      end

    if in_proper_series and Enum.all?(chunk, fn [a, b] -> abs(a - b) in 1..3 end) do
      1
    else
      0
    end
  end
end
