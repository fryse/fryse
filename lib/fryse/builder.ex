defmodule Fryse.Builder do
  @moduledoc false

  alias Fryse.Renderer
  alias Fryse.Page
  alias Fryse.FilePath
  alias Fryse.File, as: FryseFile
  alias Fryse.Folder

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

  defp build_content(%Fryse{content: content} = fryse) do
    extract_pages(content)
    |> hydrate_pages(fryse)
    |> Enum.map(&render_page(&1, fryse))
    |> sort_by_status()
  end

  defp extract_pages(%Folder{children: children}) do
    pages =
      for child <- children do
        case child do
          %FryseFile{} ->
            [%Page{file: child}]

          %Folder{} ->
            extract_pages(child)
        end
      end

    pages
    |> List.flatten()
  end

  defp hydrate_pages(pages, %Fryse{} = fryse) do
    Enum.map(pages, fn page ->
      path = FilePath.source_to_url(fryse.config, page.file.path)
      # Fryse struct won't get added here due to memory consumption
      %Page{ page | path: path}
    end)
  end

  defp render_page(%Page{file: %FryseFile{excluded: true} = file}, _fryse) do
    {:excluded, {:file, file.path}}
  end
  defp render_page(%Page{file: file} = page, %Fryse{} = fryse) do
    destination = Path.join(fryse.destination_path, FilePath.source_to_destination(fryse.config, file.path))

    # adding the Fryse struct here, at the very end, to reduce memory consumption
    new_page = %Page{page | fryse: fryse}

    try do
      Renderer.render_page(new_page, destination)
      {:ok, {:file, file.path, destination}}
    rescue
      e ->
        {:error, {:file, file.path, destination, e}}
    catch
      e ->
        {:error, {:file, file.path, destination, e}}
    end
  end

  defp sort_by_status(file_events) do
    Enum.reduce(file_events, %{ok: [], excluded: [], error: []}, fn {status, event}, acc ->
      new_events = [event | Map.get(acc, status)]
      Map.put(acc, status, new_events)
    end)
  end
end
