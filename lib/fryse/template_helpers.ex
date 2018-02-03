defmodule Fryse.TemplateHelpers do
  @moduledoc false

  alias Fryse.Page
  alias Fryse.File

  def asset(%Page{}, path), do: Path.join("/assets", to_string(path))

  def is_active(%Page{} = page, path), do: is_active(page, path, true, nil)
  def is_active(%Page{} = page, path, when_active), do: is_active(page, path, when_active, nil)

  def is_active(%Page{} = page, path, when_active, when_inactive) do
    if page.path == to_string(path), do: when_active, else: when_inactive
  end

  def link_to(%Page{} = page, %Page{file: file}), do: link_to(page, file)

  def link_to(%Page{} = page, %File{path: path}) do
    path =
      path
      |> String.split("content/", parts: 2)
      |> Enum.at(1)

    link_to(page, path)
  end

  def link_to(%Page{}, file_path) do
    path = Path.join("/", to_string(file_path))

    basename =
      path
      |> Path.basename()
      |> String.split(".")
      |> Enum.at(0)

    url_path = path |> String.replace(Path.basename(path), "")

    case basename do
      "index" -> url_path
      _ -> Path.join(url_path, [basename, ".html"])
    end
  end
end
