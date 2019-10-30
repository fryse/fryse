defmodule Fryse.FilePathTest do
  use ExUnit.Case, async: true
  alias Fryse.FilePath

  describe "source_to_destination/2" do
    test "generates the correct destination path" do
      assert "index.html" = FilePath.source_to_destination(%{}, "content/index.md")
      assert "index.html" = FilePath.source_to_destination(%{}, "/index.md")
      assert "index.html" = FilePath.source_to_destination(%{}, "index.md")

      assert "posts/test.html" =
               FilePath.source_to_destination(%{}, "content/posts/test.md")

      assert "posts/test.html" = FilePath.source_to_destination(%{}, "/posts/test.md")
    end
  end

  describe "source_to_url/2" do
    test "generates the correct url" do
      assert "/" = FilePath.source_to_url(%{}, "content/index.md")
      assert "/" = FilePath.source_to_url(%{}, "/index.md")

      assert "/posts/test.html" = FilePath.source_to_url(%{}, "content/posts/test.md")
      assert "/posts/test.html" = FilePath.source_to_url(%{}, "/posts/test.md")
    end

    test "generates the correct url with path_prefix" do
      assert "/" = FilePath.source_to_url(%{path_prefix: ""}, "content/index.md")
      assert "/" = FilePath.source_to_url(%{path_prefix: nil}, "/index.md")

      assert "/custom" = FilePath.source_to_url(%{path_prefix: "custom"}, "/index.md")

      assert "/custom/posts/test.html" = FilePath.source_to_url(%{path_prefix: "custom"}, "content/posts/test.md")
      assert "/custom/posts/test.html" = FilePath.source_to_url(%{path_prefix: "custom"}, "/posts/test.md")
    end
  end
end
