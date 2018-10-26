defmodule Fryse.Errors.MissingRequiredFile do
  @moduledoc false

  defstruct type: nil, path: nil

  @typep type :: :file | :folder
  @typep path :: String.t

  @type t :: %__MODULE__{type: type, path: path}
end

defimpl String.Chars, for: Fryse.Errors.MissingRequiredFile do
  def to_string(%{type: :file, path: path}) do
    "File '#{path}'"
  end
  def to_string(%{type: :folder, path: path}) do
    "Folder at '#{path}'"
  end
end
