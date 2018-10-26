defmodule Fryse.Errors.InvalidScriptModule do
  @moduledoc false

  defstruct type: nil, path: nil, line: nil, description: nil

  @typep type :: :error | :warning
  @typep path :: String.t
  @typep line :: integer
  @typep description :: description

  @type t :: %__MODULE__{type: type, path: path, line: line, description: description}
end

defimpl String.Chars, for: Fryse.Errors.InvalidScriptModule do
  def to_string(%{description: description}) do
    description
  end
end
