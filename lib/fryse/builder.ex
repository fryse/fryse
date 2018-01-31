defmodule Fryse.Builder do
  @moduledoc false

  def build(%Fryse{config: config}) do
    with :ok <- clean(),
         :ok <- setup(),
         :ok <- copy_theme_assets(config),
         :ok <- copy_custom_files(config) do
      :ok
    end
  end

  defp clean() do
    case File.rm_rf("_site") do
      {:ok, _} -> :ok
      {:error, reason, _} -> {:error, reason}
    end
  end

  defp setup(), do: File.mkdir("_site")

  defp copy_theme_assets(%{"theme" => theme}) do
    case File.cp_r("./themes/#{theme}/assets/", "_site/assets/") do
      {:ok, _} -> :ok
      {:error, reason, _} -> {:error, reason}
    end
  end

  defp copy_custom_files(%{"files" => files}) when is_list(files) do
    for %{"from" => from, "to" => to} <- files do
      File.cp_r(from, "_site/#{to}")
    end

    # TODO: filter through comprehension return value and look for errors
    :ok
  end

  defp copy_custom_files(_), do: :ok
end
