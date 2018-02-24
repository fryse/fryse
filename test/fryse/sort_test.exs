defmodule Fryse.SortTest do
  use ExUnit.Case, async: true
  alias Fryse.Sort

  test "parse/1 parses the given sort configuration" do
    assert [:date, :asc] = Sort.parse("date")
    assert [:date, :asc] = Sort.parse("date|asc")
    assert [:date, :desc] = Sort.parse("date|desc")
  end

  test "function/1 returns the sort function based on the sort direction" do
    items = ["A", "C", "B"]

    assert ["A", "B", "C"] = Enum.sort_by(items, & &1, Sort.function(:asc))
    assert ["C", "B", "A"] = Enum.sort_by(items, & &1, Sort.function(:desc))
  end
end
