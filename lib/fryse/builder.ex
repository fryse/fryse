defmodule Fryse.Builder do
  @moduledoc false

  alias Fryse.Renderer
  alias Fryse.Page
  alias Fryse.FilePath

  def build(%Fryse{} = fryse) do
    with :ok <- clean(fryse),
         :ok <- setup(fryse),
         :ok <- copy_theme_assets(fryse),
         :ok <- copy_custom_files(fryse),
         results <- build_content(fryse) do
      {:ok, results}
    end
  end

  defp clean(%Fryse{destination_path: dp}) do
    case File.rm_rf(dp) do
      {:ok, _} -> :ok
      {:error, reason, _} -> {:error, reason}
    end
  end

  defp setup(%Fryse{destination_path: dp}), do: File.mkdir_p(dp)

  defp copy_theme_assets(%Fryse{config: %{theme: theme}, source_path: sp, destination_path: dp}) do
    assets_source = Path.join(sp, "themes/#{theme}/assets/")
    assets_destination = Path.join(dp, "assets/")

    case File.cp_r(assets_source, assets_destination) do
      {:ok, _} -> :ok
      {:error, reason, _} -> {:error, reason}
    end
  end

  defp copy_custom_files(%Fryse{config: %{files: files}, source_path: sp, destination_path: dp}) when is_list(files) do
    for %{from: from, to: to} <- files do
      from_path = Path.join(sp, from)
      to_path = Path.join(dp, to)
      File.cp_r(from_path, to_path)
    end

    # TODO: filter through comprehension return value and look for errors
    :ok
  end

  defp copy_custom_files(_), do: :ok

  defp build_content(%Fryse{content: content, destination_path: dp} = fryse) do
    build_folder(content, fryse, dp)
    |> List.flatten()
    |> sort_by_status()
  end

  defp sort_by_status(file_events) do
    Enum.reduce(file_events, %{ok: [], excluded: [], error: []}, fn {status, event}, acc ->
      new_events = [event | Map.get(acc, status)]
      Map.put(acc, status, new_events)
    end)
  end

  defp build_folder(%Fryse.Folder{children: children}, fryse, path) do
    File.mkdir_p(path)

    for entry <- children do
      case entry do
        %Fryse.File{} ->
          render_file(entry, fryse)

        %Fryse.Folder{} ->
          build_folder(entry, fryse, Path.join(path, entry.name))
      end
    end
  end

  defp render_file(%Fryse.File{excluded: true} = file, _), do: {:excluded, {:file, file.path}}

  defp render_file(file, %Fryse{destination_path: dp} = fryse) do
    destination = Path.join(dp, FilePath.source_to_destination(fryse.config, file.path))

    page = %Page{
      fryse: fryse,
      file: file,
      path: FilePath.source_to_url(fryse.config, file.path)
    }

    try do
      Renderer.render_page(page, destination)
      {:ok, {:file, file.path, destination}}
    rescue
      e ->
        {:error, {:file, file.path, destination, e}}
    catch
      e ->
        {:error, {:file, file.path, destination, e}}
    end
  end
end
