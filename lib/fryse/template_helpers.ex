defmodule Fryse.TemplateHelpers do
  @moduledoc false

  alias Fryse.Page

  def asset(%Page{}, path), do: Path.join("/assets", to_string(path))

  def is_active(%Page{} = page, path), do: is_active(page, path, true, nil)
  def is_active(%Page{} = page, path, when_active), do: is_active(page, path, when_active, nil)

  def is_active(%Page{} = page, path, when_active, when_inactive) do
    if page.path == to_string(path), do: when_active, else: when_inactive
  end
end
