defmodule Fryse.Builder do
  @moduledoc false

  alias Fryse.Renderer

  def build(%Fryse{config: config} = fryse) do
    with :ok <- clean(),
         :ok <- setup(),
         :ok <- copy_theme_assets(config),
         :ok <- copy_custom_files(config),
         :ok <- build_content(fryse) do
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

  defp copy_theme_assets(%{theme: theme}) do
    case File.cp_r("./themes/#{theme}/assets/", "_site/assets/") do
      {:ok, _} -> :ok
      {:error, reason, _} -> {:error, reason}
    end
  end

  defp copy_custom_files(%{files: files}) when is_list(files) do
    for %{from: from, to: to} <- files do
      File.cp_r(from, "_site/#{to}")
    end

    # TODO: filter through comprehension return value and look for errors
    :ok
  end

  defp copy_custom_files(_), do: :ok

  defp build_content(%Fryse{config: config, content: content} = fryse) do
    build_folder(content, fryse, "_site/")
    :ok
  end

  defp build_folder(%Fryse.Folder{children: children}, fryse, path) do
    File.mkdir(path)

    for entry <- children do
      case entry do
        %Fryse.File{} ->
          render_file(entry, fryse, path)

        %Fryse.Folder{} ->
          build_folder(entry, fryse, Path.join(path, entry.name))
      end
    end
  end

  defp render_file(file, fryse, path) do
    if !String.starts_with?(file.name, "_") do
      Renderer.render_file(file, fryse, path)
    end
  end
end
