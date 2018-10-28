defmodule Fryse.Errors.InvalidConfigValue do
  @moduledoc false

  defstruct key: nil, recommendation: nil

  @typep key :: atom | String.t
  @typep recommendation :: String.t

  @type t :: %__MODULE__{key: key, recommendation: recommendation}
end

defimpl String.Chars, for: Fryse.Errors.InvalidConfigValue do
  def to_string(%{key: key, recommendation: recommendation}) do
    "'#{key}' has an invalid value. #{recommendation}"
  end
end
