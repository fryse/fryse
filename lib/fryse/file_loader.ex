defmodule Fryse.FileLoader do
  @moduledoc false

  alias Fryse.Content

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

    content = %Content{
      frontmatter: parsed_frontmatter,
      content: parsed_content
    }

    {:ok, content}
  end

  defp parse(content, path, ".yaml"), do: parse(content, path, ".yml")
  defp parse(content, path, ".yml"), do: parse_yaml(content, path)
  defp parse(content, path, ".markdown"), do: parse(content, path, ".md")
  defp parse(content, _path, ".md"), do: parse_markdown(content)
  defp parse(content, _, _), do: {:ok, content}

  defp parse_yaml(content, path) do
    try do
      parsed =
        content
        |> YamlElixir.read_from_string()

      {:ok, parsed}
    catch
      _ -> {:error, "#{path} not parsable"}
    end
  end

  defp parse_markdown(content) do
    {status, content, _} = Earmark.as_html(content)
    {status, content}
  end
end
