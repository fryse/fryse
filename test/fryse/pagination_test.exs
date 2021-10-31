defmodule Fryse.PaginationTest do
  use Fryse.TestCase, async: true
  alias Fryse.Pagination


  test "config/2 returns the config for a given pagination", %{fryse: fryse} do
    assert {:ok, config} = Pagination.config("posts", fryse)
    assert "posts" = config.name

    assert {:error, :not_found} = Pagination.config("something", fryse)
  end

  test "listing_pages/2 returns the pages to render for a given pagination", %{fryse: fryse} do
    assert {:ok, pages} = Pagination.listing_pages("posts", fryse)

    assert 1 = Enum.count(pages)
    assert 2 = pages |> Enum.at(0) |> Map.get(:page_number)
    assert "Posts" = pages |> Enum.at(0) |> Map.get(:file) |> Map.get(:document) |> Map.get(:frontmatter) |> Map.get(:title)

    {:ok, config} = Pagination.config("posts", fryse)
    assert {:ok, pages} = Pagination.listing_pages(config, fryse)
    assert 1 = Enum.count(pages)

    assert {:error, :not_found} = Pagination.listing_pages("something", fryse)
   end

  test "listing_page_path/2 returns the file path for a given pagination and page", %{fryse: fryse} do
    {:ok, "/posts.html.eex"} = Pagination.listing_page_path("posts", 0, fryse)
    {:ok, "/posts.html.eex"} = Pagination.listing_page_path("posts", 1, fryse)
    {:ok, "/posts/2.html"} = Pagination.listing_page_path("posts", 2, fryse)

    {:ok, config} = Pagination.config("posts", fryse)
    {:ok, "/posts.html.eex"} = Pagination.listing_page_path(config, 0, fryse)
    {:ok, "/posts.html.eex"} = Pagination.listing_page_path(config, 1, fryse)
    {:ok, "/posts/2.html"} = Pagination.listing_page_path(config, 2, fryse)

    assert {:error, :not_found} = Pagination.listing_page_path("something", 1, fryse)
  end

  test "listing_page_url/2 returns the url for a given pagination and page", %{fryse: fryse} do
    {:ok, "/posts.html"} = Pagination.listing_page_url("posts", 0, fryse)
    {:ok, "/posts.html"} = Pagination.listing_page_url("posts", 1, fryse)
    {:ok, "/posts/2.html"} = Pagination.listing_page_url("posts", 2, fryse)

    {:ok, config} = Pagination.config("posts", fryse)
    {:ok, "/posts.html"} = Pagination.listing_page_url(config, 0, fryse)
    {:ok, "/posts.html"} = Pagination.listing_page_url(config, 1, fryse)
    {:ok, "/posts/2.html"} = Pagination.listing_page_url(config, 2, fryse)

    assert {:error, :not_found} = Pagination.listing_page_url("something", 1, fryse)
  end

  test "page_items/3 returns the items for a given pagination and page", %{fryse: fryse} do
    assert {:ok, items} = Pagination.page_items("posts", 1, fryse)
    assert 1 = Enum.count(items)

    assert {:ok, items} = Pagination.page_items("posts", 2, fryse)
    assert 1 = Enum.count(items)

    assert {:ok, items} = Pagination.page_items("posts", 0, fryse)
    assert 0 = Enum.count(items)

    assert {:ok, items} = Pagination.page_items("posts", 3, fryse)
    assert 0 = Enum.count(items)

    {:ok, config} = Pagination.config("posts", fryse)
    assert {:ok, items} = Pagination.page_items(config, 1, fryse)
    assert 1 = Enum.count(items)

    assert {:error, :not_found} = Pagination.page_items("something", 0, fryse)
    assert {:error, :not_found} = Pagination.page_items("something", 1, fryse)
    assert {:error, :not_found} = Pagination.page_items("something", 2, fryse)
    assert {:error, :not_found} = Pagination.page_items("something", 3, fryse)
  end

  test "page_count/2 returns the page count for a given pagination or config", %{fryse: fryse} do
    assert {:ok, 2} = Pagination.page_count("posts", fryse)

    {:ok, config} = Pagination.config("posts", fryse)
    assert {:ok, 2} = Pagination.page_count(config, fryse)

    assert {:error, :not_found} = Pagination.config("something", fryse)
  end
end
