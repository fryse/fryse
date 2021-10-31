defmodule Fryse.TemplateHelpers do
  @moduledoc false

  alias Fryse.Content
  alias Fryse.Pagination
  alias Fryse.Page
  alias Fryse.File
  alias Fryse.Document
  alias Fryse.FilePath

  def asset(%Page{fryse: %Fryse{config: %{path_prefix: p}}}, path) when is_nil(p) == false do
    Path.join(["/", p, "/assets", to_string(path)])
  end
  def asset(%Page{}, path), do: Path.join("/assets", to_string(path))

  def files_from(%Page{} = page, path), do: files_from(page, path, [])

  def files_from(%Page{fryse: fryse}, path, options) do
    path = to_string(path)

    case Content.find_pages(path, fryse, options) do
      {:ok, files} -> files
      {:error, :not_found} -> []
    end
  end

  def pagination(%Page{page_number: nil} = page, name), do: pagination(%Page{page | page_number: 1}, name)

  def pagination(%Page{fryse: fryse, page_number: page_number}, name) do
    name = to_string(name)

    case Pagination.page_items(name, page_number, fryse) do
      {:ok, items} -> items
      {:error, :not_found} -> []
    end
  end

  def pagination_link(%Page{fryse: fryse}, name, page_number) do
    name = to_string(name)

    case Pagination.listing_page_url(name, page_number, fryse) do
      {:ok, url} -> url
      {:error, :not_found} -> ""
    end
  end

  def frontmatter(%File{document: document}), do: document.frontmatter
  def frontmatter(%Document{frontmatter: frontmatter}), do: frontmatter

  def frontmatter(data, key, default \\ nil)

  def frontmatter(%File{document: document}, key, default),
    do: frontmatter(document, key, default)

  def frontmatter(%Document{frontmatter: frontmatter}, key, default),
    do: frontmatter(frontmatter, key, default)

  def frontmatter(frontmatter, key, default) when is_binary(key),
    do: frontmatter(frontmatter, String.to_atom(key), default)

  def frontmatter(frontmatter, key, default) when is_list(key),
    do: frontmatter(frontmatter, to_string(key), default)

  def frontmatter(frontmatter, key, default) do
    Map.get(frontmatter, key, default)
  end

  def is_active(%Page{} = page, path), do: is_active(page, path, true, false)
  def is_active(%Page{} = page, path, when_active), do: is_active(page, path, when_active, false)

  def is_active(%Page{} = page, path, when_active, when_inactive) do
    if page.url == FilePath.source_to_url(page.fryse.config, to_string(path)) do
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
