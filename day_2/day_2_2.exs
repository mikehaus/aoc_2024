defmodule RowSafetyValidator do
  def get_safe_row_count() do
    safe_rows =
      File.stream!("report.txt")
      |> Stream.with_index()
      |> Stream.map(fn {line, _i} -> read_line(line) end)
      |> count_dampened_sequential_lines()

    IO.puts(safe_rows)
  end

  def read_line(line) do
    line
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def count_dampened_sequential_lines(stream) do
    stream
    |> Enum.count(fn line ->
      0..length(line)
      |> Stream.map(&List.delete_at(line, &1))
      |> Enum.any?(fn
        [a, a | _] ->
          false

        [a, b | _] = line ->
          sign = div(a - b, abs(a - b))

          line
          |> Enum.chunk_every(2, 1, :discard)
          |> Enum.all?(fn [a, b] ->
            (sign * (a - b)) in 1..3
          end)
      end)
    end)
  end
end

RowSafetyValidator.get_safe_row_count()
