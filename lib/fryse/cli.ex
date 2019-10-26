defmodule Fryse.CLI do
  @moduledoc false

  def main(args) do
    parsed = OptionParser.parse(args, strict: [])

    case find_command(parsed) do
      {:error, :not_found} -> show_not_found_notice(parsed)
      {:ok, :no_command} -> show_no_command_notice()
      {_, module} -> invoke_command(module, args)
    end
  end

  def commands() do
    [
      {:new, Fryse.CLI.New},
      {:build, Fryse.CLI.Build},
      {:serve, Fryse.CLI.Serve},
      {:help, Fryse.CLI.Help}
    ]
  end

  def find_command({_, [], _}) do
    {:ok, :no_command}
  end
  def find_command({_, [cmd | _], _}) do
    cmd = String.to_atom(cmd)

    commands()
    |> Enum.find({:error, :not_found}, fn {command, _} -> command == cmd end)
  end
  def find_command(cmd) do
    find_command({[], [cmd], []})
  end

  defp invoke_command(module, args) do
    apply(module, :run, [args])
  end

  defp show_no_command_notice() do
    Mix.shell().info("Fryse #{Application.spec(:fryse, :vsn)} \n")

    show_available_commands()
  end

  def show_available_commands() do
    Mix.shell().info("Available commands:")

    command_width = greatest_command_length() + 3
    for {cmd, module} <- commands() do
      command = Atom.to_string(cmd)
      shortdoc = Mix.Task.shortdoc(module)
      Mix.shell().info("fryse #{String.pad_trailing(command, command_width)} # #{shortdoc}")
    end
  end

  defp show_not_found_notice({_, [cmd | _], _}) do
    Mix.shell().error("The command \"#{cmd}\" could not be found \n")

    show_available_commands()
  end

  defp greatest_command_length() do
    commands()
    |> Enum.map(fn {cmd, _} -> Atom.to_string(cmd) end)
    |> Enum.map(&String.length/1)
    |> Enum.max(fn -> 0 end)
  end
end
