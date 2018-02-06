defmodule Fryse.CLI.Build do
  @moduledoc false

  def run(_args) do
    with {:ok, %Fryse{} = fryse} <- Fryse.index("."), {:ok, results} = Fryse.build(fryse) do
      IO.inspect(fryse)
      IO.inspect(results)
      show_results(results)
    end
  end

  defp show_results(%{ok: ok, excluded: excluded, error: error}) do
    show_ok_results(ok)
    show_excluded_results(excluded)
    show_error_results(error)
  end

  defp show_ok_results(results) do
    IO.puts("Files Created: #{Enum.count(results)}")
  end

  defp show_excluded_results(results) when length(results) > 0 do
    IO.puts("Files Excluded: #{Enum.count(results)}")

    for {:file, path} <- results do
      IO.puts(path)
    end
  end

  defp show_excluded_results(_), do: nil

  defp show_error_results(results) when length(results) > 0 do
    IO.puts("Files Not Rendered: #{Enum.count(results)}")

    for error <- results do
      show_file_error(error)
    end
  end

  defp show_error_results(_), do: nil

  defp show_file_error({:file, source, _destination, error}) do
    error_description =
      case error do
        %{description: description, file: "nofile", line: line} ->
          "#{description} in #{source} on line #{line} (line counting starts below the frontmatter section)"

        %{description: description, file: file, line: line} ->
          "#{description} in #{file} on line #{line}"

        %{message: message, file: "nofile", line: line} ->
          # for some reason, it contains the proper line number
          "#{message} in #{source} on line #{line}"

        %{message: message, file: file, line: line} ->
          "#{message} in #{file} on line #{line}"

        %File.Error{action: action, path: path} ->
          "cannot #{action} #{path}"
      end

    IO.puts("#{red(source)}: #{error_description}")
  end

  defp red(message) do
    IO.ANSI.format([:red, :bright, message])
  end
end
