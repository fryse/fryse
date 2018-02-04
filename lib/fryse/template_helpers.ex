defmodule Fryse.TemplateHelpers do
  @moduledoc false

  alias Fryse.Page
  alias Fryse.File
  alias Fryse.FilePath

  def asset(%Page{}, path), do: Path.join("/assets", to_string(path))

  def is_active(%Page{} = page, path), do: is_active(page, path, true, nil)
  def is_active(%Page{} = page, path, when_active), do: is_active(page, path, when_active, nil)

  def is_active(%Page{} = page, path, when_active, when_inactive) do
    if page.path == to_string(path), do: when_active, else: when_inactive
  end

  def link_to(%Page{} = page, %Page{file: file}), do: link_to(page, file)

  def link_to(%Page{fryse: fryse}, %File{path: path}) do
    FilePath.source_to_url(fryse.config, path)
  end

  def link_to(%Page{fryse: fryse}, file_path) do
    FilePath.source_to_url(fryse.config, to_string(file_path))
  end
end
