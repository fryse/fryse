defmodule Fryse.Builder do
  @moduledoc false

  alias Fryse.Renderer
  alias Fryse.Page

  def build(%Fryse{config: config} = fryse) do
    with :ok <- clean(),
         :ok <- setup(),
         :ok <- copy_theme_assets(config),
         :ok <- copy_custom_files(config),
         results <- build_content(fryse) do
      show_results(results)
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

  defp render_file(%Fryse.File{excluded: true} = file, _, _), do: {:excluded, {:file, file.path}}

  defp render_file(file, fryse, path) do
    destination = destination_path(path, file)

    url_path =
      destination
      |> String.replace("_site", "")
      |> String.replace("index.html", "")

    page = %Page{
      fryse: fryse,
      file: file,
      path: url_path
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

  defp destination_path(path, file) do
    Path.join(path, [file.name, ".html"])
  end

  defp show_results(%{ok: ok, excluded: excluded, error: error}) do
    show_ok_results(ok)
    show_excluded_results(excluded)
    show_error_results(error)
  end

  defp show_ok_results(results) do
    IO.puts("Files Created: #{Enum.count(results)}")
  end

  defp show_excluded_results(results) when length(results) > 0 do
    IO.puts("Files Excluded: #{Enum.count(results)}")

    for {:file, path} <- results do
      IO.puts(path)
    end
  end

  defp show_excluded_results(_), do: nil

  defp show_error_results(results) when length(results) > 0 do
    IO.puts("Files Not Rendered: #{Enum.count(results)}")

    for error <- results do
      show_file_error(error)
    end
  end

  defp show_error_results(_), do: nil

  defp show_file_error({:file, source, _destination, error}) do
    error_description =
      case error do
        %{description: description, file: "nofile", line: line} ->
          "#{description} in #{source} on line #{line} (line counting starts below the frontmatter section)"

        %{description: description, file: file, line: line} ->
          "#{description} in #{file} on line #{line}"
      end

    IO.puts("#{source}: #{error_description}")
  end
end
