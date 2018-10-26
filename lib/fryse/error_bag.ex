defmodule Fryse.ErrorBag do
  @moduledoc false

  defstruct context: nil, errors: []

  @typep context :: nil | atom
  @typep error :: struct | map | String.t

  @type t :: %__MODULE__{context: context, errors: list(error)}
end
