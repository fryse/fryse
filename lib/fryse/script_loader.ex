defmodule Fryse.ScriptLoader do
  @moduledoc false

  def load_for(%Fryse{config: %{theme: theme}}) do
    project_scripts = project_scripts()
    theme_scripts = theme_scripts(theme)

    files = project_scripts ++ theme_scripts

    case Kernel.ParallelCompiler.compile(files) do
      {:ok, _, _} -> :ok
      {:error, errors, warnings} -> {:error, errors, warnings}
    end
  end

  defp project_scripts() do
    Path.wildcard("./scripts/**/*.{ex,exs}")
  end

  defp theme_scripts(theme) do
    Path.wildcard("./themes/#{theme}/scripts/**/*.{ex,exs}")
  end
end
