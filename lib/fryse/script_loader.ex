defmodule Fryse.ScriptLoader do
  @moduledoc false

  def load_for(%Fryse{config: %{theme: theme}, source_path: source_path}) do
    project_scripts = project_scripts(source_path)
    theme_scripts = theme_scripts(source_path, theme)

    files = project_scripts ++ theme_scripts

    case Kernel.ParallelCompiler.compile(files) do
      {:ok, _, _} -> :ok
      {:error, errors, warnings} -> {:error, errors, warnings}
    end
  end

  defp project_scripts(source_path) do
    Path.wildcard(Path.join(source_path, "scripts/**/*.{ex,exs}"))
  end

  defp theme_scripts(source_path, theme) do
    Path.wildcard(Path.join(source_path, "themes/#{theme}/scripts/**/*.{ex,exs}"))
  end
end
