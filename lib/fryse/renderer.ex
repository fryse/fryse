defmodule Fryse.Renderer do
  @moduledoc false

  alias Fryse.Page
  alias Fryse.Document

  def render_page(%Page{} = page, destination) do
    content =
      EEx.eval_file(
        get_layout(page.file, page.fryse.config),
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

  def render(%Page{} = page, %Fryse.File{document: document}), do: render(page, document)

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

    all_assigns =
      [page: page, fryse: page.fryse, config: page.fryse.config, data: page.fryse.data] ++ assigns

    EEx.eval_file(path, [assigns: all_assigns], functions: functions())
  end

  defp get_layout(%Fryse.File{document: %Document{frontmatter: %{layout: layout}}}, %{
         theme: theme
       }) do
    "./themes/#{theme}/layouts/#{layout}.html.eex"
  end

  defp get_layout(_file, %{theme: theme}) do
    "./themes/#{theme}/layouts/default.html.eex"
  end

  defp functions() do
    [
      {Enum, [empty?: 1]},
      {Fryse.Renderer, [include: 3, render: 2]},
      {Fryse.TemplateHelpers,
       [
         asset: 2,
         files_from: 2,
         files_from: 3,
         frontmatter: 1,
         frontmatter: 2,
         frontmatter: 3,
         is_active: 2,
         is_active: 3,
         is_active: 4,
         link_to: 2
       ]}
    ]
  end
end
