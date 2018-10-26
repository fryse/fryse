defmodule Fryse.Indexer do
  @moduledoc false

  alias Fryse.FileLoader
  alias Fryse.ErrorBag
  alias Fryse.Errors.MissingRequiredFile

  def index(path) do
    source_path = Path.expand(path)
    destination_path = Path.join(source_path, "_site")

    with :ok <- check_required_files(source_path),
         {:ok, config} <- load_config(source_path),
         {:ok, data} <- load_data(source_path),
         {:ok, content} <- load_content(source_path) do
      fryse = %Fryse{
        config: config,
        data: data,
        content: content,
        source_path: source_path,
        destination_path: destination_path,
      }

      {:ok, fryse}
    end
  end

  defp check_required_files(path) do
    files = [
      {:file, "config.yml"},
      {:folder, "data"},
      {:folder, "content"}
    ]

    missing =
      files
      |> Enum.map(
           fn {type, file_path} ->
             {File.exists?(Path.join(path, file_path)), {type, file_path}}
           end)
      |> Enum.filter(fn {exists, _} -> exists == false end)
      |> Enum.map(fn {_, file_info} -> file_info end)

    case missing do
      [] -> :ok
      missing ->
        errors = Enum.map(missing, fn {type, file_path} -> %MissingRequiredFile{type: type, path: file_path} end)

        error_bag = %ErrorBag{
          context: :required_files,
          errors: errors
        }

        {:error, error_bag}
    end
  end

  defp load_config(path) do
    path
    |> Path.join("config.yml")
    |> FileLoader.load_file()
    #TODO: Handle config merge with default config
    #TODO: Handle config validation
    #TODO: Think about theme config and its validation
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
      |> index_content_folder(path)

    {:ok, content}
  end

  defp index_content_folder(path, source_path) do
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

        name =
          case excluded do
            true ->
              "_" <> name = name
              name

            false ->
              name
          end

        %Fryse.File{
          name: name,
          path: Path.relative_to(path, source_path),
          excluded: excluded,
          document: document
        }

      File.dir?(path) ->
        %Fryse.Folder{
          name: Path.basename(path),
          path: Path.relative_to(path, source_path),
          children:
            File.ls!(path) |> Enum.map(&Path.join(path, &1)) |> Enum.map(&index_content_folder(&1, source_path))
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
