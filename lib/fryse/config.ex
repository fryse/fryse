defmodule Fryse.Config do
  @moduledoc false

  alias Fryse.ErrorBag
  alias Fryse.Errors.MissingConfigValue
  alias Fryse.Errors.InvalidConfigValue

  @checked_keys [
    :path_prefix,
    :clean_urls,
    :theme,
    :files,
    :paginations
  ]

  @default_config %{
    path_prefix: nil,
    clean_urls: false,
    theme: nil,
    files: [],
    paginations: []
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

  def validate_key(:path_prefix, value) when (is_binary(value) == false) and (is_nil(value) == false) do
    %InvalidConfigValue{
      key: :path_prefix,
      recommendation: "Must be a string."
    }
  end

  def validate_key(:clean_urls, value) when value not in [true, false] do
    %InvalidConfigValue{
      key: :clean_urls,
      recommendation: "Must be a boolean."
    }
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

  def validate_key(:paginations, []), do: :ok

  def validate_key(:paginations, value) when value in [nil, ""] do
    %MissingConfigValue{key: :paginations}
  end

  def validate_key(:paginations, value) when is_list(value) do
    errors =
      value
      |> Enum.with_index() |> Enum.map(&validate_pagination_item/1)
      |> List.flatten()

    case errors do
      [] -> :ok
      [error | _rest] -> error
    end
  end

  def validate_key(:paginations, _value) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Use a list of objects with 'name', 'from_folder', 'size', 'sort', 'path', 'list_template' and 'first_page' keys."
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

  def override(config, config2) do
    Map.merge(config, config2, fn _k, _v1, v2 ->
      v2
    end)
  end

  defp only_errors(:ok), do: false
  defp only_errors(_), do: true

  defp valid_files_item?(item), do: item[:from] not in [nil, ""] && item[:to] not in [nil, ""]

  defp validate_pagination_item({item, index}) when is_map(item) do
    [:name, :from_folder, :size, :sort, :path, :list_template, :first_page]
    |> Enum.map(&(validate_pagination_item_key({&1, index}, item)))
    |> Enum.reject(fn value -> :ok == value end)
  end

  defp validate_pagination_item({_item, index}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: Use a list of objects with 'name', 'from_folder', 'size', 'sort', 'path', 'list_template' and 'first_page' keys."
    }
  end

  defp validate_pagination_item_key({:name, index}, %{name: ""}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'name' cannot be an empty string."
    }
  end
  defp validate_pagination_item_key({:name, _}, %{name: name}) when is_binary(name), do: :ok
  defp validate_pagination_item_key({:name, index}, %{name: _}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'name' must be a string."
    }
  end
  defp validate_pagination_item_key({:name, index}, _) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'name' has to be set."
    }
  end

  defp validate_pagination_item_key({:from_folder, index}, %{from_folder: ""}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'from_folder' cannot be an empty string."
    }
  end
  defp validate_pagination_item_key({:from_folder, _}, %{from_folder: from_folder}) when is_binary(from_folder), do: :ok
  defp validate_pagination_item_key({:from_folder, index}, %{from_folder: _}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'from_folder' must be a string."
    }
  end
  defp validate_pagination_item_key({:from_folder, index}, _) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'from_folder' has to be set."
    }
  end

  defp validate_pagination_item_key({:size, _}, %{size: size}) when is_number(size) and size > 0, do: :ok
  defp validate_pagination_item_key({:size, index}, %{size: _}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'size' must be a positive number."
    }
  end
  defp validate_pagination_item_key({:size, index}, _) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'size' has to be set."
    }
  end

  defp validate_pagination_item_key({:sort, index}, %{sort: ""}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'sort' cannot be an empty string."
    }
  end
  defp validate_pagination_item_key({:sort, _}, %{sort: sort}) when is_binary(sort), do: :ok
  defp validate_pagination_item_key({:sort, index}, %{sort: _}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'sort' must be a string."
    }
  end
  defp validate_pagination_item_key({:sort, index}, _) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'sort' has to be set."
    }
  end

  defp validate_pagination_item_key({:path, index}, %{path: ""}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'path' cannot be an empty string."
    }
  end
  defp validate_pagination_item_key({:path, _}, %{path: path}) when is_binary(path), do: :ok
  defp validate_pagination_item_key({:path, index}, %{path: _}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'path' must be a string."
    }
  end
  defp validate_pagination_item_key({:path, index}, _) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'path' has to be set."
    }
  end

  defp validate_pagination_item_key({:list_template, index}, %{list_template: ""}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'list_template' cannot be an empty string."
    }
  end
  defp validate_pagination_item_key({:list_template, _}, %{list_template: list_template}) when is_binary(list_template), do: :ok
  defp validate_pagination_item_key({:list_template, index}, %{list_template: _}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'list_template' must be a string."
    }
  end
  defp validate_pagination_item_key({:list_template, index}, _) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'list_template' has to be set."
    }
  end

  defp validate_pagination_item_key({:first_page, index}, %{first_page: ""}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'first_page' cannot be an empty string."
    }
  end
  defp validate_pagination_item_key({:first_page, _}, %{first_page: first_page}) when is_binary(first_page), do: :ok
  defp validate_pagination_item_key({:first_page, index}, %{first_page: _}) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'first_page' must be a string."
    }
  end
  defp validate_pagination_item_key({:first_page, index}, _) do
    %InvalidConfigValue{
      key: :paginations,
      recommendation: "Index #{index}: 'first_page' has to be set."
    }
  end
end
