defmodule Fryse.ContentTest do
  use Fryse.TestCase, async: true
  alias Fryse.Content


  test "find_page/2 returns a file from the given path", %{fryse: fryse} do
    {:ok, file} = Content.find_page("/posts/your-new-fryse-blog.md", fryse)
    assert "Welcome to Your New Fryse Website" = file.document.frontmatter.title

    {:error, :not_found} = Content.find_page("/posts/non-existent.md", fryse)
  end

  test "find_pages/2 returns files from the given path", %{fryse: fryse} do
    assert {:ok, pages} = Content.find_pages("/posts", fryse)
    assert 2 = pages |> Enum.count()

    assert {:error, :not_found} = Content.find_pages("/posts/non-existent", fryse)
  end

  test "find_pages/3 returns files from the given path and the given options", %{fryse: fryse} do
    assert {:ok, pages} = Content.find_pages("/posts", fryse, excluded: true)
    assert 3 = pages |> Enum.count()

    assert {:ok, pages} = Content.find_pages("/posts", fryse, index: true)
    assert 3 = pages |> Enum.count()

    assert {:ok, pages} = Content.find_pages("/posts", fryse, sort: "order|asc")
    assert ["Welcome to Your New Fryse Website", "Second Post"] =
             pages |> Enum.map(fn file -> file.document.frontmatter.title end)


    assert {:ok, pages} = Content.find_pages("/posts", fryse, sort: "order|desc")
    assert ["Second Post", "Welcome to Your New Fryse Website"] =
             pages |> Enum.map(fn file -> file.document.frontmatter.title end)


    assert {:ok, pages} = Content.find_pages("/posts", fryse, offset: 1)
    assert 1 = pages |> Enum.count()

    assert {:ok, pages} = Content.find_pages("/posts", fryse, limit: 1)
    assert 1 = pages |> Enum.count()
  end
end
