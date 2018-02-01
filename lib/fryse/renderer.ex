defmodule Fryse.Renderer do
  @moduledoc false

  alias Fryse.Document

  def render_file(%Fryse.File{document: document} = file, fryse, path) do
    content =
      EEx.eval_file(
        get_layout(file, fryse.config),
        [
          assigns: [
            fryse: fryse,
            config: fryse.config,
            data: fryse.data,
            document: document,
            frontmatter: document.frontmatter,
            content: document.content
          ]
        ],
        functions: functions()
      )

    File.write(Path.join(path, [file.name, ".html"]), content)
  end

  def render(%Fryse{} = fryse, %Document{} = document) do
    EEx.eval_string(
      document.content,
      [
        assigns: [
          fryse: fryse,
          config: fryse.config,
          data: fryse.data,
          document: document,
          frontmatter: document.frontmatter,
          content: document.content
        ]
      ],
      functions: functions()
    )
  end

  defp get_layout(_file, %{theme: theme}) do
    "./themes/#{theme}/layouts/default.html.eex"
  end

  defp functions() do
    [
      {Fryse.Renderer, [render: 2]}
    ]
  end
end
