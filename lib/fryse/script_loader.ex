defmodule Fryse.ScriptLoader do
  @moduledoc false

  alias Fryse.ErrorBag
  alias Fryse.Errors.InvalidScriptModule

  def load_for(%Fryse{config: %{theme: theme}, source_path: source_path}) do
    project_scripts = project_scripts(source_path)
    theme_scripts = theme_scripts(source_path, theme)

    files = project_scripts ++ theme_scripts

    case Kernel.ParallelCompiler.compile(files) do
      {:ok, _, _} -> :ok
      {:error, errors, warnings} ->
        errors = Enum.map(errors, fn {file, line, description} ->
          %InvalidScriptModule{type: :error, path: file, line: line, description: description}
        end)

        warnings = Enum.map(warnings, fn {file, line, description} ->
          %InvalidScriptModule{type: :warning, path: file, line: line, description: description}
        end)

        error_bag = %ErrorBag{
          context: :compile,
          errors: errors ++ warnings
        }

        {:error, error_bag}
    end
  end

  defp project_scripts(source_path) do
    Path.wildcard(Path.join(source_path, "scripts/**/*.{ex,exs}"))
  end

  defp theme_scripts(source_path, theme) do
    Path.wildcard(Path.join(source_path, "themes/#{theme}/scripts/**/*.{ex,exs}"))
  end
end
