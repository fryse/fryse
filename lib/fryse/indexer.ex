defmodule Fryse.Indexer do
  @moduledoc false

  alias Fryse.FileLoader

  def index(path) do
    with :ok <- check_required_files(path),
         {:ok, config} <- load_config(path),
         {:ok, data} <- load_data(path),
         {:ok, content} <- load_content(path) do
      fryse = %Fryse{
        config: config,
        data: data,
        content: content
      }

      {:ok, fryse}
    end
  end

  defp check_required_files(path) do
    with true <- File.exists?(Path.join(path, "config.yml")),
         true <- File.exists?(Path.join(path, "data")),
         true <- File.exists?(Path.join(path, "content")) do
      :ok
    else
      _ ->
        # TODO: Find out which files
        {:error, "Some files/ folders are missing"}
    end
  end

  defp load_config(path) do
    path
    |> Path.join("config.yml")
    |> FileLoader.load_file()
  end

  defp load_data(path) do
    data_path = path |> Path.join("data")

    data =
      data_path
      |> File.ls!()
      |> Enum.map(&Path.join(data_path, &1))
      |> Enum.map(&get_data_file/1)
      |> Enum.filter(fn {status, _} -> status != :error end)
      |> Enum.map(fn {:ok, file} -> file end)
      |> Enum.into(%{})

    {:ok, data}
  end

  defp load_content(path) do
    content =
      path
      |> Path.join("content")
      |> index_content_folder()

    {:ok, content}
  end

  defp index_content_folder(path) do
    cond do
      File.regular?(path) ->
        {:ok, document} = FileLoader.load_content_file(path)

        # TODO: Do this properly. Maybe use basename() and handle html.eex things separately
        name =
          path
          |> Path.basename()
          |> String.split(".")
          |> Enum.at(0)

        excluded = String.starts_with?(name, "_")

        %Fryse.File{
          name: name,
          path: path,
          excluded: excluded,
          document: document
        }

      File.dir?(path) ->
        %Fryse.Folder{
          name: Path.basename(path),
          path: path,
          children:
            File.ls!(path) |> Enum.map(&Path.join(path, &1)) |> Enum.map(&index_content_folder/1)
        }

      true ->
        %{}
    end
  end

  defp get_data_file(path) do
    basename = Path.basename(path, Path.extname(path)) |> String.to_atom()

    case FileLoader.load_file(path) do
      {:ok, content} ->
        {:ok, {basename, content}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
