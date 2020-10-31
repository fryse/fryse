defmodule Fryse.FilePath do
  @moduledoc false

  def source_to_destination(config, "content" <> path), do: source_to_destination(config, path)

  def source_to_destination(config, path) do
    name =
      path
      |> Path.basename()
      |> String.split(".")
      |> Enum.at(0)

    path =
      path
      |> Path.split()
      |> Enum.drop(-1)


    path = case path do
      [] -> ""
      _ -> Path.join(path)
    end

    path =
      case path do
        "/" <> rest -> rest
        _ -> path
      end

    case config.clean_urls do
      false -> Path.join(path, [name, ".html"])
      true -> case name do
                "index" -> Path.join([path, "index.html"])
                _ -> Path.join([path, name, "index.html"])
              end
    end
  end

  def source_to_url(config, "content" <> path), do: source_to_url(config, path)

  def source_to_url(config, path) do
    path = Path.join("/", path)

    basename =
      path
      |> Path.basename()
      |> String.split(".")
      |> Enum.at(0)

    url_path = path |> String.replace(Path.basename(path), "")

    url = case basename do
      "index" -> url_path
      _ -> case config.clean_urls do
            false -> Path.join(url_path, [basename, ".html"])
            true -> Path.join([url_path, basename])
           end
    end

    case path_prefix(config) do
      "" -> url
      prefix ->
        case url do
          "/" -> prefix
          url -> Path.join(prefix, url)
        end
    end
  end

  defp path_prefix(%{path_prefix: nil}), do: ""
  defp path_prefix(%{path_prefix: prefix}), do: Path.join("/", prefix)
  defp path_prefix(_), do: ""
end
