defmodule Fryse.FilePath do
  @moduledoc false

  def source_to_destination(config, "./content" <> path), do: source_to_destination(config, path)

  def source_to_destination(_config, path) do
    name =
      path
      |> Path.basename()
      |> String.split(".")
      |> Enum.at(0)

    path =
      path
      |> Path.split()
      |> Enum.drop(-1)
      |> Path.join()

    path = Path.join("_site", path)

    Path.join(path, [name, ".html"])
  end

  def source_to_url(config, "./content" <> path), do: source_to_url(config, path)

  def source_to_url(_config, path) do
    path = Path.join("/", path)

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
