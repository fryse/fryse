defmodule Fryse.FilePathTest do
  use ExUnit.Case, async: true
  alias Fryse.FilePath

  test "source_to_destination/2 generates the correct destination path" do
    assert "./_site/index.html" = FilePath.source_to_destination({}, "./content/index.md")
    assert "./_site/index.html" = FilePath.source_to_destination({}, "/index.md")

    assert "./_site/posts/test.html" =
             FilePath.source_to_destination({}, "./content/posts/test.md")

    assert "./_site/posts/test.html" = FilePath.source_to_destination({}, "/posts/test.md")
  end

  test "source_to_url/2 generates the correct url" do
    assert "/" = FilePath.source_to_url({}, "./content/index.md")
    assert "/" = FilePath.source_to_url({}, "/index.md")

    assert "/posts/test.html" = FilePath.source_to_url({}, "./content/posts/test.md")
    assert "/posts/test.html" = FilePath.source_to_url({}, "/posts/test.md")
  end
end
