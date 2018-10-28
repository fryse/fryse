defmodule Fryse.Errors.MissingConfigValue do
  @moduledoc false

  defstruct key: nil

  @typep key :: atom | String.t

  @type t :: %__MODULE__{key: key}
end

defimpl String.Chars, for: Fryse.Errors.MissingConfigValue do
  def to_string(%{key: key}) do
    "'#{key}' has to be set"
  end
end
