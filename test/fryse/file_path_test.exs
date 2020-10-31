defmodule Fryse.FilePathTest do
  use ExUnit.Case, async: true
  alias Fryse.FilePath

  @config %{
    clean_urls: false
  }
  
  @config_clean_urls %{
    clean_urls: true
  }
  
  describe "source_to_destination/2" do
    test "generates the correct destination path" do
      assert "index.html" = FilePath.source_to_destination(@config, "content/index.md")
      assert "index.html" = FilePath.source_to_destination(@config, "/index.md")
      assert "index.html" = FilePath.source_to_destination(@config, "index.md")

      assert "posts/test.html" =
               FilePath.source_to_destination(@config, "content/posts/test.md")

      assert "posts/test.html" = FilePath.source_to_destination(@config, "/posts/test.md")
    end

    test "generates the correct destination path with clean urls" do
      assert "index.html" = FilePath.source_to_destination(@config_clean_urls, "content/index.md")
      assert "index.html" = FilePath.source_to_destination(@config_clean_urls, "/index.md")
      assert "index.html" = FilePath.source_to_destination(@config_clean_urls, "index.md")

      assert "posts/test/index.html" =
               FilePath.source_to_destination(@config_clean_urls, "content/posts/test.md")

      assert "posts/test/index.html" = FilePath.source_to_destination(@config_clean_urls, "/posts/test.md")
    end
  end

  describe "source_to_url/2" do
    test "generates the correct url" do
      assert "/" = FilePath.source_to_url(@config, "content/index.md")
      assert "/" = FilePath.source_to_url(@config, "/index.md")

      assert "/posts/test.html" = FilePath.source_to_url(@config, "content/posts/test.md")
      assert "/posts/test.html" = FilePath.source_to_url(@config, "/posts/test.md")
    end

    test "generates the correct url with clean urls" do
      assert "/" = FilePath.source_to_url(@config_clean_urls, "content/index.md")
      assert "/" = FilePath.source_to_url(@config_clean_urls, "/index.md")

      assert "/posts/test" = FilePath.source_to_url(@config_clean_urls, "content/posts/test.md")
      assert "/posts/test" = FilePath.source_to_url(@config_clean_urls, "/posts/test.md")
    end

    test "generates the correct url with path_prefix" do
      assert "/" = FilePath.source_to_url(%{path_prefix: "", clean_urls: false}, "content/index.md")
      assert "/" = FilePath.source_to_url(%{path_prefix: nil, clean_urls: false}, "/index.md")

      assert "/custom" = FilePath.source_to_url(%{path_prefix: "custom", clean_urls: false}, "/index.md")

      assert "/custom/posts/test.html" = FilePath.source_to_url(%{path_prefix: "custom", clean_urls: false}, "content/posts/test.md")
      assert "/custom/posts/test.html" = FilePath.source_to_url(%{path_prefix: "custom", clean_urls: false}, "/posts/test.md")
    end

    test "generates the correct url with path_prefix and clean urls" do
      assert "/" = FilePath.source_to_url(%{path_prefix: "", clean_urls: true}, "content/index.md")
      assert "/" = FilePath.source_to_url(%{path_prefix: nil, clean_urls: true}, "/index.md")

      assert "/custom" = FilePath.source_to_url(%{path_prefix: "custom", clean_urls: true}, "/index.md")

      assert "/custom/posts/test" = FilePath.source_to_url(%{path_prefix: "custom", clean_urls: true}, "content/posts/test.md")
      assert "/custom/posts/test" = FilePath.source_to_url(%{path_prefix: "custom", clean_urls: true}, "/posts/test.md")
    end
  end
end
