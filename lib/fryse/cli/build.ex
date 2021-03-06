defmodule Fryse.CLI.Build do
  use Fryse.Command

  alias Fryse.ErrorBag
  alias Fryse.FileLoader
  alias Fryse.Config

  @shortdoc "Builds static files"

  @moduledoc """
  Builds static files. It expects the Fryse project to
  be in the folder in which the command is executed in.

      fryse build [--config-override PATH]

  An `--config-override` or `-o` option can be given to override
  the config with another config file. The values in the given
  config file will override the values in the normal config.
  This can be seen as a form of environment config.

  The static files will be written to `_site`.
  """

  @doc false
  def run(args) do
    {switches, _, _} = OptionParser.parse(
      args,
      switches: [
        debug: :boolean,
        config_override: :string
      ],
      aliases: [
        o: :config_override
      ]
    )
    debug = Keyword.get(switches, :debug, false)
    config_override = Keyword.get(switches, :config_override, false)

    with {:indexing, {:ok, %Fryse{} = fryse}}         <- {:indexing, Fryse.index(".")},
         {:config_override, {:ok, %Fryse{} = fryse}}  <- {:config_override, apply_override_config(fryse, config_override)},
         {:config_validation, :ok}                    <- {:config_validation, Fryse.validate_config(fryse)},
         {:script_loading, :ok}                       <- {:script_loading, Fryse.load_scripts(fryse)},
         {:building, {:ok, results}}                  <- {:building, Fryse.build(fryse)} do
      if debug do
        IO.inspect(fryse)
        IO.inspect(results)
      end

      show_results(results)
    else
      {task, {:error, reason}} ->
        show_task_errors(task, reason)
        stop(1)
      {task, reason} ->
        show_task_errors(task, reason)
        stop(1)
    end
  end

  defp apply_override_config(%Fryse{} = fryse, false), do: {:ok, fryse}
  defp apply_override_config(%Fryse{} = fryse, path) do
    absolute_path = Path.expand(path)

    with {:ok, config} <- FileLoader.load_file(absolute_path),
         overridden_config <- Config.override(fryse.config, config) do

      new_fryse = %Fryse{fryse | config: overridden_config}

      {:ok, new_fryse}
    end
  end

  defp show_task_errors(:indexing, %ErrorBag{context: :required_files, errors: errors}) do
    IO.puts(red("Some required files/ folders are missing:"))
    for error <- errors do
      IO.puts "- #{error}"
    end
  end
  defp show_task_errors(:config_validation, %ErrorBag{context: :validate, errors: errors}) do
    IO.puts(red("Config validation failed:"))
    for error <- errors do
      IO.puts "- #{error}"
    end
  end
  defp show_task_errors(:script_loading, %ErrorBag{context: :compile, errors: errors}) do
    IO.puts(red("Loading script modules failed:"))
    for error <- errors do
      IO.puts "- #{error}"
    end
  end
  defp show_task_errors(task, error) do
    IO.puts(red("Something went wrong!"))
    IO.inspect(task, label: "Task")
    IO.inspect(error, label: "Error")
    IO.puts "Please go to https://github.com/fryse/fryse/issues and file an issue"
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
      IO.puts("  #{path}")
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
    #TODO: no case clause matching: %UndefinedFunctionError{arity: 2, exports: nil, function: :author, module: FriseDefaultTheme, reason: nil}
    error_description =
      case error do
        %KeyError{key: :path, term: %Fryse.Page{}} ->
          "'@page.path' is deprecated, use '@page.url'"

        %KeyError{key: key} ->
          "Cannot access key '#{key}' (usage might be in layout file)"

        %{description: description, file: "nofile", line: line} ->
          "#{description} in #{source} on line #{line} (line counting starts below the frontmatter section)"

        %{description: description, file: file, line: line} ->
          "#{description} in #{file} on line #{line}"

        %{message: message, file: "nofile", line: line} ->
          "#{message} in #{source} on line #{line} (line counting starts below the frontmatter section)"

        %{message: message, file: file, line: line} ->
          "#{message} in #{file} on line #{line}"

        %File.Error{action: action, path: path} ->
          "cannot #{action} #{path}"

        %{message: message} ->
          "#{message} in #{source}"
      end

    IO.puts("  #{red(source)}: #{error_description}")
  end

  defp red(message) do
    IO.ANSI.format([:red, :bright, message])
  end
end
