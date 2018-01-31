defmodule Fryse do
  @moduledoc """
  Documentation for Fryse.
  """

  alias Fryse.{Indexer, Builder}

  defstruct config: nil,
            data: nil,
            content: nil

  def index(path) do
    Indexer.index(path)
  end

  def build(%Fryse{} = fryse) do
    Builder.build(fryse)
  end
end
