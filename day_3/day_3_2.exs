defmodule InputParser do
  @parsable_vals ~r/mul\([0-9]+,[0-9]+\)|don't\(\)|do\(\)/
  @non_nums ~r/[^0-9]/
  @do_fn ~r/do\(\)/
  @dont ~r/don't\(\)/

  def parse do
    File.stream!("day_3.txt")
    |> Stream.with_index()
    |> Stream.flat_map(fn {line, _i} -> isolate_parsable_values(line) end)
    |> Enum.flat_map(fn val -> val end)
    |> remove_dont_vals()
    |> Enum.map(fn parsed_mul -> isolate_numbers(parsed_mul) end)
    |> Enum.map(fn [a, b] -> a * b end)
    |> Enum.sum()
    |> IO.inspect(label: "Value is: ")
  end

  def isolate_parsable_values(line) do
    Regex.scan(@parsable_vals, line)
  end

  def isolate_numbers(parsed_mul) do
    Regex.split(@non_nums, parsed_mul)
    |> Enum.reject(fn str -> str == "" end)
    |> Enum.map(fn str -> String.to_integer(str) end)
  end

  def remove_dont_vals(parsable_vals) do
    remove_dont_vals(:do, parsable_vals)
  end

  def remove_dont_vals(_, []), do: []

  def remove_dont_vals(:dont, vals) do
    vals_til_do = Enum.take_while(vals, fn val -> !Regex.match?(@do_fn, val) end)

    rest = vals -- vals_til_do

    remove_dont_vals(:do, rest)
  end

  def remove_dont_vals(:do, vals) do
    vals_til_dont = Enum.take_while(vals, fn val -> !Regex.match?(@dont, val) end)

    rest = vals -- vals_til_dont

    vals_without_dont = remove_dont_vals(:dont, rest)

    (vals_til_dont ++ vals_without_dont)
    |> Enum.reject(fn val -> val == "do()" end)
  end
end

InputParser.parse()
