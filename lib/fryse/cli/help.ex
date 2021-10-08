defmodule Fryse.CLI.Help do
  use Fryse.Command

  require IO.ANSI.Docs

  @shortdoc "Prints help information for commands"

  @moduledoc """
  Lists all commands or prints the documentation for a given command.

  ## Arguments

      fryse help            - prints all commands and their short descriptions
      fryse help COMMAND    - prints full docs for the given command
  """

  @doc false
  def run(args) do
    {_, args, _} = OptionParser.parse(args, strict: [])

    case args do
      ["help"] -> show_commands()
      ["help", command | _] -> show_help(command)
    end
  end

  defp show_commands() do
    Fryse.CLI.show_available_commands()
  end

  defp show_help(command) do
    case Fryse.CLI.find_command(command) do
      {:error, :not_found} ->
        Mix.shell().error("The command \"#{command}\" could not be found")

      {_, module} ->
        opts = [width: width()]
        doc = apply(module, :moduledoc, [])
        print_heading("fryse #{command}", opts)
        print(doc, opts)
    end
  end

  defp width() do
    case :io.columns() do
      {:ok, width} -> min(width, 80)
      {:error, _} -> 80
    end
  end

  defp print_heading(heading, opts) do
    IO.ANSI.Docs.__info__(:functions)

    if function_exported?(IO.ANSI.Docs, :print_heading, 2) do
      apply(IO.ANSI.Docs, :print_heading, [heading, opts])
    end

    if function_exported?(IO.ANSI.Docs, :print_headings, 2) do
      apply(IO.ANSI.Docs, :print_headings, [[heading], opts])
    end
  end

  defp print(doc, opts) do
    IO.ANSI.Docs.__info__(:functions)

    new_doc = case doc do
      false -> ""
      _ -> doc
    end

    if function_exported?(IO.ANSI.Docs, :print_markdown, 2) do
      apply(IO.ANSI.Docs, :print_markdown, [new_doc, opts])
    else
      if function_exported?(IO.ANSI.Docs, :print, 2) do
        apply(IO.ANSI.Docs, :print, [new_doc, opts])
      end
    end
  end
end
