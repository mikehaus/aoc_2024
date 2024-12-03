defmodule InputParser do
  @mul ~r/mul\([0-9]+,[0-9]+\)/
  @non_nums ~r/[^0-9]/

  def parse do
    count =
      File.stream!("day_3.txt")
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, _i} -> isolate_muls(line) end)
      |> Enum.map(fn parsed_mul -> isolate_numbers(parsed_mul) end)
      |> Enum.map(fn [a, b] -> a * b end)
      |> Enum.sum
      |> IO.inspect(label: "DEBUG")
  end

  def isolate_muls(line) do
    Regex.scan(@mul, line)
  end

  def isolate_numbers(parsed_mul) do
    Regex.split(@non_nums, Enum.at(parsed_mul, 0))
    |> Enum.reject(fn str -> str == "" end)
    |> Enum.map(fn str -> String.to_integer(str) end)
  end
end

InputParser.parse
