defmodule Fryse.CLI.Build do
  @moduledoc false

  def run(args) do
    "."
    |> Fryse.index()
    |> IO.inspect()
  end
end
