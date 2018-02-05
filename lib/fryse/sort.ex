defmodule Fryse.Sort do
  @moduledoc false

  def parse(sort) do
    case String.split(sort, "|") do
      [key] ->
        [String.to_atom(key), :asc]

      [key, sort] ->
        [String.to_atom(key), String.to_atom(sort)]
    end
  end

  def function(:desc), do: &>=/2
  def function(_), do: &<=/2
end
