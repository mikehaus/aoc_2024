defmodule DayOne do
  def calc_similarity do
    {l1, l2} =
      File.stream!("day1.txt")
      |> Stream.with_index()
      |> Stream.flat_map(fn {line, _index} -> split_line(line) end)
      |> Stream.with_index()
      |> reduce_stream_into_sorted_values()

    value =
      l1
      |> sum_similarities(l2)

    IO.puts(value)
  end

  def split_line(line) do
    line
    |> String.split(~r/\s+/, trim: true)
  end

  def reduce_stream_into_sorted_values(stream) do
    stream
    |> reduce_into_alternating_arrays()
    |> sort_lists_tuple()
  end

  def reduce_into_alternating_arrays(stream) do
    stream
    |> Enum.reduce({[], []}, fn {element, index}, {list1, list2} ->
      if rem(index, 2) == 0 do
        {[element | list1], list2}
      else
        {list1, [element | list2]}
      end
    end)
  end

  def sort_lists_tuple({l1, l2}), do: {Enum.sort(l1), Enum.sort(l2)}

  def sum_similarities(l1, l2) do
    l1_occurrences =
      l1
      |> Enum.map(fn l1_val -> Enum.count(l2, fn l2_val -> l1_val == l2_val end) end)

    l1
    |> Enum.with_index()
    |> Enum.map(fn {l1_val, i} -> Enum.at(l1_occurrences, i) * String.to_integer(l1_val) end)
    |> Enum.sum()
  end
end

DayOne.calc_similarity()
