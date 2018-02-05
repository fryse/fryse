defmodule Fryse.TemplateHelper do
  @moduledoc false

  alias Fryse.Page
  alias Fryse.File
  alias Fryse.Folder
  alias Fryse.FilePath
  alias Fryse.Sort

  def asset(%Page{}, path), do: Path.join("/assets", to_string(path))

  def files_from(%Page{} = page, path), do: files_from(page, path, [])

  def files_from(%Page{fryse: fryse}, path, options) do
    path = to_string(path)

    pieces =
      case String.starts_with?(path, "/") do
        true -> path |> Path.split() |> Enum.drop(1)
        false -> path |> Path.split()
      end

    case get_content_items(pieces, fryse.content.children, options) do
      {:error, :not_found} -> []
      files -> files
    end
  end

  defp get_content_items([], content, options) do
    excluded = Keyword.get(options, :excluded, false)
    index = Keyword.get(options, :index, false)
    sort = Keyword.get(options, :sort, false)

    content
    |> files_filter_excluded(excluded)
    |> files_filter_index(index)
    |> files_sort(sort)
  end

  defp get_content_items([name | path], content, options) do
    folder = for %Folder{} = folder <- content, do: folder

    sub =
      folder
      |> Enum.filter(fn %Folder{name: f_name} -> f_name == name end)
      |> Enum.at(0)

    case sub do
      %Folder{children: children} -> get_content_items(path, children, options)
      nil -> {:error, :not_found}
    end
  end

  defp files_filter_excluded(content, excluded) do
    case excluded do
      true -> for %File{} = file <- content, do: file
      false -> for %File{excluded: false} = file <- content, do: file
    end
  end

  defp files_filter_index(files, index) do
    case index do
      true ->
        files

      false ->
        files
        |> Enum.reject(fn %File{name: name} -> name == "index" end)
    end
  end

  defp files_sort(files, sort) do
    case sort do
      false ->
        files

      arg ->
        [key, sort] = Sort.parse(arg)

        mapper = fn file -> Map.get(file.document.frontmatter, key, 0) end
        sorter = Sort.function(sort)

        Enum.sort_by(files, mapper, sorter)
    end
  end

  def is_active(%Page{} = page, path), do: is_active(page, path, true, nil)
  def is_active(%Page{} = page, path, when_active), do: is_active(page, path, when_active, nil)

  def is_active(%Page{} = page, path, when_active, when_inactive) do
    if page.path == FilePath.source_to_url(page.fryse.config, to_string(path)) do
      when_active
    else
      when_inactive
    end
  end

  def link_to(%Page{} = page, %Page{file: file}), do: link_to(page, file)

  def link_to(%Page{fryse: fryse}, %File{path: path}) do
    FilePath.source_to_url(fryse.config, path)
  end

  def link_to(%Page{fryse: fryse}, file_path) do
    FilePath.source_to_url(fryse.config, to_string(file_path))
  end
end
