defmodule Fryse.Config do
  @moduledoc false

  alias Fryse.ErrorBag
  alias Fryse.Errors.MissingConfigValue
  alias Fryse.Errors.InvalidConfigValue

  @checked_keys [
    :theme,
    :files
  ]

  @default_config %{
    theme: nil,
    files: []
  }

  def validate(%{} = config) do
    errors =
      @checked_keys
      |> Enum.map(&(validate_key(&1, config[&1])))
      |> Enum.filter(&only_errors/1)

    case errors do
      [] -> :ok
      errors ->
        error_bag = %ErrorBag{
          context: :validate,
          errors: errors
        }

        {:error, error_bag}
    end
  end

  def validate_key(:theme, value) when value in [nil, ""] do
    %MissingConfigValue{key: :theme}
  end

  def validate_key(:files, value) when is_list(value) do
    valid_items = Enum.all?(value, &valid_files_item?/1)

    case valid_items do
      true -> :ok
      false ->
        %InvalidConfigValue{
          key: :files,
          recommendation: "Use a list of objects with 'from' and 'to' keys, containing paths relative to the project root."
        }
    end
  end
  def validate_key(:files, value) when value not in [nil] do
    %InvalidConfigValue{
      key: :files,
      recommendation: "Use a list of objects with 'from' and 'to' keys, containing paths relative to the project root."
    }
  end

  def validate_key(_, _) do
    :ok
  end

  def default_config() do
    @default_config
  end

  def merge(config, default) do
    Map.merge(config, default, fn _k, v1, _v2 ->
      v1
    end)
  end

  defp only_errors(:ok), do: false
  defp only_errors(_), do: true

  defp valid_files_item?(item), do: item[:from] not in [nil, ""] && item[:to] not in [nil, ""]
end
