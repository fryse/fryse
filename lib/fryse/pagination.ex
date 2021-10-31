defmodule Fryse.Pagination do
  @moduledoc false

  alias Fryse.Page
  alias Fryse.TemplateHelpers
  alias Fryse.Content
  alias Fryse.File
  alias Fryse.FilePath

  def config(name, %Fryse{} = fryse) when is_binary(name) do
    config =
      fryse.config.paginations
      |> Enum.find(fn pagination -> pagination.name == name end)

    case config do
      nil -> {:error, :not_found}
      config -> {:ok, config}
    end
  end

  def listing_pages(name, %Fryse{} = fryse) when is_binary(name) do
    case config(name, fryse) do
      {:ok, config} -> listing_pages(config, fryse)
      error -> error
    end
  end

  def listing_pages(config, %Fryse{} = fryse) when is_map(config) do
    with {:ok, page_count} <- page_count(config, fryse),
         {:ok, template} <- Content.find_page(config.list_template, fryse),
         {:ok, pages} <- create_pages(page_count, config, template, fryse) do
      {:ok, pages}
    end
  end

  def listing_page_path(name, page_number, %Fryse{} = fryse) when is_number(page_number) and page_number <= 0 do
    listing_page_path(name, 1, fryse)
  end

  def listing_page_path(name, page_number, %Fryse{} = fryse) when is_binary(name) and is_number(page_number) do
    case config(name, fryse) do
      {:ok, config} -> listing_page_path(config, page_number, fryse)
      error -> error
    end
  end

  def listing_page_path(%{path: path, first_page: first_page}, page_number, %Fryse{} = _fryse)
      when is_number(page_number) do

    path = case page_number do
      1 -> first_page
      _ -> String.replace(path, ":page", "#{page_number}") <> ".html"
    end

    {:ok, path}
  end

  def listing_page_url(name, page_number, %Fryse{} = fryse) when is_number(page_number) and page_number <= 0 do
    listing_page_url(name, 1, fryse)
  end

  def listing_page_url(name, page_number, %Fryse{} = fryse) when is_binary(name) and is_number(page_number) do
    case config(name, fryse) do
      {:ok, config} -> listing_page_url(config, page_number, fryse)
      error -> error
    end
  end

  def listing_page_url(config, page_number, %Fryse{} = fryse)
      when is_map(config) and is_number(page_number) do

    with {:ok, path} <- listing_page_path(config, page_number, fryse),
         link <- FilePath.source_to_url(fryse.config, path) do
      {:ok, link}
    end
  end

  def page_items(name, page_number, fryse) when is_number(page_number) and page_number <= 0 do
    case config(name, fryse) do
      {:ok, _config} -> {:ok, []}
      error -> error
    end
  end

  def page_items(name, page_number, %Fryse{} = fryse) when is_binary(name) and is_number(page_number) do
    case config(name, fryse) do
      {:ok, config} -> page_items(config, page_number, fryse)
      error -> error
    end
  end

  def page_items(%{sort: sort, from_folder: folder, size: size}, page_number, %Fryse{} = fryse) when is_number(page_number) do
    with options <- [sort: sort, excluded: false, index: false, offset: (page_number - 1) * size, limit: size],
         {:ok, items} <- Content.find_pages(folder, fryse, options) do
      {:ok, items}
    end
  end

  def page_count(name, %Fryse{} = fryse) when is_binary(name) do
    case config(name, fryse) do
      {:ok, config} -> page_count(config, fryse)
      error -> error
    end
  end

  def page_count(%{sort: sort, from_folder: from_folder, size: size}, %Fryse{} = fryse) do
    options = [sort: sort, excluded: false, index: false]

    count =
      TemplateHelpers.files_from(%Page{fryse: fryse}, from_folder, options)
      |> Enum.count()
      |> (fn count -> ceil(count / size) end).()

    {:ok, count}
  end

  defp create_pages(page_count, _config, _template, _fryse) when page_count < 2, do: {:ok, []}

  defp create_pages(page_count, config, %File{} = template, %Fryse{} = fryse) when is_map(config) do
    files =
      2..page_count
      |> Enum.into([])
      |> Enum.map(fn page_number ->
        {:ok, path} = listing_page_path(config, page_number, fryse)

        file = %File{
          name: page_number,
          excluded: false,
          path: path,
          document: template.document
        }

        %Page{
          page_number: page_number,
          file: file
        }
      end)

    {:ok, files}
  end
end
