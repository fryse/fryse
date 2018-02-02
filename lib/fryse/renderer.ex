defmodule Fryse.Renderer do
  @moduledoc false

  alias Fryse.Page
  alias Fryse.Document

  def render_file(%Fryse.File{} = file, fryse, path) do
    destination = Path.join(path, [file.name, ".html"])

    url_path =
      destination
      |> String.replace("_site", "")
      |> String.replace("index.html", "")

    page = %Page{
      fryse: fryse,
      file: file,
      path: url_path
    }

    content =
      EEx.eval_file(
        get_layout(file, fryse.config),
        [
          assigns: [
            page: page,
            fryse: page.fryse,
            config: page.fryse.config,
            data: page.fryse.data,
            document: page.file.document,
            frontmatter: page.file.document.frontmatter,
            content: page.file.document.content
          ]
        ],
        functions: functions()
      )

    File.write(destination, content)
  end

  def render(%Page{} = page, %Document{} = document) do
    EEx.eval_string(
      document.content,
      [
        assigns: [
          page: page,
          fryse: page.fryse,
          config: page.fryse.config,
          data: page.fryse.data,
          document: page.file.document,
          frontmatter: page.file.document.frontmatter,
          content: page.file.document.content
        ]
      ],
      functions: functions()
    )
  end

  def include(%Page{} = page, file, assigns) do
    path = Path.join("./themes/#{page.fryse.config.theme}/includes/", file)

    all_assigns = [fryse: page.fryse, config: page.fryse.config, data: page.fryse.data] ++ assigns

    EEx.eval_file(path, [assigns: all_assigns], functions: functions())
  end

  defp get_layout(_file, %{theme: theme}) do
    "./themes/#{theme}/layouts/default.html.eex"
  end

  defp functions() do
    [
      {Fryse.Renderer, [include: 3, render: 2]}
    ]
  end
end
