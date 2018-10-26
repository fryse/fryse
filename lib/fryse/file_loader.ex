defmodule Fryse.FileLoader do
  @moduledoc false

  alias Fryse.Document

  def load_file(path) do
    ext = Path.extname(path)

    path
    |> File.read!()
    |> parse(path, ext)
  end

  def load_content_file(path) do
    content = path |> File.read!()

    [frontmatter, content] =
      case String.split(content, ~r/\n-{3,}\n/, parts: 2) do
        [frontmatter, content] -> [frontmatter, content]
        [content] -> ["", content]
        _ -> ["", ""]
      end

    {:ok, parsed_frontmatter} = parse_yaml(frontmatter, path)
    {:ok, parsed_content} = parse(content, path, Path.extname(path))

    document = %Document{
      frontmatter: parsed_frontmatter,
      content: parsed_content
    }

    {:ok, document}
  end

  defp parse(content, path, ".yaml"), do: parse(content, path, ".yml")
  defp parse(content, path, ".yml"), do: parse_yaml(content, path)
  defp parse(content, path, ".markdown"), do: parse(content, path, ".md")
  defp parse(content, _path, ".md"), do: parse_markdown(content)
  defp parse(content, _, _), do: {:ok, content}

  def parse_yaml(content, path) do
    try do
      parsed =
        content
        |> YamlElixir.read_from_string!()
        |> atom_key_map()

      {:ok, parsed}
    catch
      _ -> {:error, "#{path} not parsable"}
    end
  end

  defp parse_markdown(content) do
    {status, content, _} = Earmark.as_html(content)
    {status, content}
  end

  defp atom_key_map(map) when is_map(map) do
    Enum.reduce(map, %{}, fn {key, value}, result ->
      Map.put(result, String.to_atom(key), atom_key_map(value))
    end)
  end

  defp atom_key_map(list) when is_list(list), do: Enum.map(list, &atom_key_map/1)
  defp atom_key_map(value), do: value
end
