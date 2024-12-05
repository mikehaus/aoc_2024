defmodule Day5 do
  def solve() do
    prep_for_parse()
    |> parse()
  end

  def parse(input) do
    {graph, updates} =
      input
      |> separate_lists()
      |> format_rules_and_updates()

    correct_updates = get_correct_updates(graph, updates)

    incorrect_updates =
      Enum.map(updates -- correct_updates, fn bad ->
        Enum.sort(bad, fn a, b -> a not in graph[b] end)
      end)

    sum_center_updates(incorrect_updates) |> IO.inspect(label: "DEBUG")
  end

  defp prep_for_parse() do
    {:ok, input} = File.read("day_5.txt")

    input
    |> String.trim()
    |> String.split("\n")
  end

  defp separate_lists(input) do
    input
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
  end

  defp format_rules_and_updates([rules, updates]) do
    graph =
      rules
      |> transform_numbers_to_tuple()
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.update(acc, k, [v], fn existing ->
          [v | existing]
        end)
      end)

    rules = Enum.map(rules, &String.split(&1, "|", trim: true))

    # Need to append missing values so it doesn't error on calculation
    missing_values =
      rules
      |> Enum.reject(fn [_a | b] ->
        !is_nil(Map.get(graph, Enum.at(b, 0)))
      end)
      |> Enum.uniq_by(fn [_a, b] -> b end)
      |> Enum.map(fn [_a, b] -> b end)
      |> Enum.reduce(%{}, fn v, acc ->
        Map.put(acc, v, [])
      end)

    graph =
      Map.merge(graph, missing_values)

    updates =
      updates
      |> Enum.map(fn val -> String.split(val, ",") end)

    {graph, updates}
  end

  defp transform_numbers_to_tuple(l) do
    l
    |> Enum.map(fn val ->
      val
      |> String.split("|")
      |> get_tuple()
    end)
  end

  defp get_tuple(nums) do
    {Enum.at(nums, 0), Enum.at(nums, 1)}
  end

  defp get_correct_updates(graph, updates) do
    Enum.filter(updates, fn update ->
      update
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce_while(true, fn [parent, child], _ ->
        curr_list = Map.get(graph, parent)

        if child in curr_list do
          {:cont, true}
        else
          {:halt, false}
        end
      end)
    end)
  end

  defp sum_center_updates(list) do
    list
    |> Enum.map(fn l ->
      center_index = div(length(l), 2)

      l
      |> Enum.at(center_index)
      |> String.to_integer()
    end)
    |> Enum.sum()
  end
end

Day5.solve()
