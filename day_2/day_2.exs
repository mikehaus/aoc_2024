# From a file input find how many are safe
# Safe = row of info is either all increasing or all decreasing
# min of 1 Max of 3

defmodule RowSafetyValidator do
  def get_safe_row_count() do
    safe_rows =
      File.stream!("report.txt")
      |> Stream.with_index()
      |> Stream.map(fn {line, _i} -> read_line(line) end)
      |> Enum.map(fn row -> row end)
      |> Enum.map(fn row -> safe?(row) end)
      |> Enum.count(fn val -> val == true end)

    IO.puts(safe_rows)
  end

  def read_line(line) do
    line
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def safe?(row) do
    increasing?(row) || decreasing?(row)
  end

  def increasing?(row) do
    Enum.chunk_every(row, 2, 1, :discard)
    |> Enum.all?(fn [a, b] -> a < b && b - a >= 1 && b - a <= 3 end)
  end

  def decreasing?(row) do
    Enum.chunk_every(row, 2, 1, :discard)
    |> Enum.all?(fn [a, b] -> a > b && abs(a - b) >= 1 && abs(a - b) <= 3 end)
  end
end

RowSafetyValidator.get_safe_row_count()
