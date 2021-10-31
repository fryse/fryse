defmodule Fryse.Content do
  @moduledoc false

  alias Fryse.File
  alias Fryse.Folder
  alias Fryse.Sort

  def find_page(path, %Fryse{} = fryse) when is_binary(path) do
    pieces =
      case String.starts_with?(path, "/") do
        true -> path |> Path.split() |> Enum.drop(1)
        false -> path |> Path.split()
      end

    get_content_item(pieces, fryse.content.children)
  end

  def find_pages(path, %Fryse{} = fryse, options \\ []) when is_binary(path) do
    pieces =
      case String.starts_with?(path, "/") do
        true -> path |> Path.split() |> Enum.drop(1)
        false -> path |> Path.split()
      end

    get_content_items(pieces, fryse.content.children, options)
  end

  defp get_content_item([name | []], content) do
    files = for %File{} = file <- content, do: file

    found = Enum.filter(files, fn %File{path: path} -> String.ends_with?(path, name) end)

    case found do
      [file] -> {:ok, file}
      [] -> {:error, :not_found}
    end
  end

  defp get_content_item([name | path], content) do
    folder = for %Folder{} = folder <- content, do: folder

    sub =
      folder
      |> Enum.filter(fn %Folder{name: f_name} -> f_name == name end)
      |> Enum.at(0)

    case sub do
      %Folder{children: children} -> get_content_item(path, children)
      nil -> {:error, :not_found}
    end
  end

  defp get_content_items([], content, options) do
    excluded = Keyword.get(options, :excluded, false)
    index = Keyword.get(options, :index, false)
    sort = Keyword.get(options, :sort, false)
    offset = Keyword.get(options, :offset, false)
    limit = Keyword.get(options, :limit, false)

    items =
      content
      |> files_filter_excluded(excluded)
      |> files_filter_index(index)
      |> files_sort(sort)
      |> files_offset(offset)
      |> files_limit(limit)

    {:ok, items}
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

  defp files_filter_index(files, true), do: files

  defp files_filter_index(files, false) do
    files
    |> Enum.reject(fn %File{name: name} -> name == "index" end)
  end

  defp files_sort(files, false), do: files

  defp files_sort(files, arg) do
    [key, sort] = Sort.parse(arg)

    mapper = fn file -> Map.get(file.document.frontmatter, key, 0) end
    sorter = Sort.function(sort)

    Enum.sort_by(files, mapper, sorter)
  end

  defp files_offset(files, false), do: files

  defp files_offset(files, offset) when is_integer(offset) do
    files |> Enum.drop(offset)
  end

  defp files_offset(files, _), do: files

  defp files_limit(files, false), do: files

  defp files_limit(files, limit) when is_integer(limit) do
    files |> Enum.take(limit)
  end

  defp files_limit(files, _), do: files
end
