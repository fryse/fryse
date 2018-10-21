defmodule Fryse do
  @moduledoc """
  Documentation for Fryse.

  Full documentation will follow soon.
  """

  alias Fryse.{Indexer, ScriptLoader, Builder}

  defstruct config: nil,
            data: nil,
            content: nil,
            source_path: nil,
            destination_path: nil

  def index(path) do
    Indexer.index(path)
  end

  def load_scripts(%Fryse{} = fryse) do
    ScriptLoader.load_for(fryse)
  end

  def build(%Fryse{} = fryse) do
    Builder.build(fryse)
  end
end
