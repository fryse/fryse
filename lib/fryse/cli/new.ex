defmodule Fryse.CLI.New do
  use Fryse.Command

  @shortdoc "Creates a new Fryse project"

  @moduledoc """
  Creates a new Fryse project.
  It expects the name of the project as argument.

      fryse new NAME

  A project will be created in a new folder named after the project.
  The project name will also be used to name script modules and for the example config.
  """

  alias HTTPoison.Response

  def run(args) when args in [[], ["new"]] do
    message = """
    Invalid Arguments
    Usage: fryse new <name>
    """

    IO.puts(message)
  end

  def run(args) do
    boilerplate_url = "https://github.com/fryse/starter-project/archive/master.zip"

    with name <- Enum.at(args, 1),
         :ok <- check_folder_does_not_exist(Path.expand(name)),
         parts <- extract_name_parts(name),
         {:ok, boilerplate} <- load_boilerplate(boilerplate_url),
         {:ok, files} <- extract(boilerplate),
         files <- adjust_file_paths(files, parts),
         files <- adjust_file_contents(files, parts),
         :ok <- write_files(files, Path.expand(name)) do
      IO.puts("Done!")
    else
      {:error, :folder_exists} ->
        IO.puts("Folder already exists!")

      {:error, :load_boilerplate} ->
        IO.puts("Could not load boilerplate! Check your internet connection.")
    end
  end

  defp check_folder_does_not_exist(path) do
    case File.exists?(path) do
      true -> {:error, :folder_exists}
      false -> :ok
    end
  end

  defp extract_name_parts(name) do
    name
    |> String.split("-")
    |> Enum.map(&Macro.underscore/1)
    |> Enum.map(fn string -> String.split(string, "_") end)
    |> List.flatten()
  end

  defp load_boilerplate(url) do
    IO.puts("Loading boilerplate ...")

    try do
      %Response{body: body, status_code: 200} =
        HTTPoison.get!(
          url,
          [],
          hackney: [{:follow_redirect, true}]
        )

      {:ok, body}
    rescue
      _ -> {:error, :load_boilerplate}
    catch
      _ -> {:error, :load_boilerplate}
    end
  end

  defp extract(boilerplate) do
    IO.puts("Extracting files ...")
    :zip.unzip(boilerplate, [:memory])
  end

  defp adjust_file_paths(files, parts) do
    files
    |> Enum.map(fn {path, content} ->
      new_path =
        path
        |> Path.split()
        |> Enum.drop(1)
        |> Path.join()
        |> String.replace("fryse_page_script_module", parts_to_module_filename(parts))

      {new_path, content}
    end)
  end

  defp adjust_file_contents(files, parts) do
    files
    |> Enum.map(fn {path, content} ->
      new_content =
        content
        |> String.replace("fryse_page_name", parts_to_page_name(parts))
        |> String.replace("FrysePageScriptModule", parts_to_module_name(parts))

      {path, new_content}
    end)
  end

  defp write_files(files, path) do
    IO.puts("Writing files to #{path} ...")

    File.mkdir_p!(path)

    files
    |> Enum.each(fn {file_path, content} ->
      dest = Path.join(path, file_path)

      File.mkdir_p!(Path.dirname(dest))
      File.write!(dest, content)
    end)

    :ok
  end

  defp parts_to_page_name(parts) do
    parts
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp parts_to_module_filename(parts) do
    parts
    |> Enum.map(&String.downcase/1)
    |> Enum.join("_")
  end

  defp parts_to_module_name(parts) do
    parts
    |> Enum.map(&String.capitalize/1)
    |> Enum.join("")
  end
end
