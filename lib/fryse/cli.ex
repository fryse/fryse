defmodule Fryse.CLI do
  @moduledoc false

  def main(args) do
    parsed = OptionParser.parse(args)

    case find_command(parsed) do
      {:error, :not_found} -> show_not_found_notice(parsed)
      {_, module} -> invoke_command(module, args)
    end
  end

  def commands() do
    [
      {:new, Fryse.CLI.New},
      {:build, Fryse.CLI.Build},
      {:serve, Fryse.CLI.Serve}
    ]
  end

  defp find_command({_, [cmd | _], _}) do
    cmd = String.to_atom(cmd)

    commands()
    |> Enum.find({:error, :not_found}, fn {command, _} -> command == cmd end)
  end

  defp invoke_command(module, args) do
    apply(module, :run, [args])
  end

  defp show_not_found_notice({_, [cmd | _], _}) do
    Mix.shell().error("Command \"#{cmd}\" could not be found")
  end
end
