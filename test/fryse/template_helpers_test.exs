defmodule Fryse.TemplateHelpersTest do
  use Fryse.TestCase, async: true
  alias Fryse.TemplateHelpers

  test "asset/2 returns the correct path" do
    assert "/assets/img/logo.png" = TemplateHelpers.asset(%Page{}, "/img/logo.png")
    assert "/assets/img/logo.png" = TemplateHelpers.asset(%Page{}, "img/logo.png")
    assert "/assets/img/logo.png" = TemplateHelpers.asset(%Page{}, 'img/logo.png')

    page = %Page{
      fryse: %Fryse{
        config: %{
          path_prefix: "custom"
        }
      }
    }
    assert "/custom/assets/img/logo.png" = TemplateHelpers.asset(page, "/img/logo.png")
  end

  test "files_from/2 returns files from the given folder", %{fryse: fryse} do
    page = %Page{
      fryse: fryse,
      file: nil,
      url: ""
    }

    assert 2 = TemplateHelpers.files_from(page, "/posts") |> Enum.count()
    assert 2 = TemplateHelpers.files_from(page, '/posts') |> Enum.count()
  end

  test "files_from/3 returns files from the given folder and the given options", %{fryse: fryse} do
    page = %Page{
      fryse: fryse
    }

    assert 3 = TemplateHelpers.files_from(page, "/posts", excluded: true) |> Enum.count()
    assert 3 = TemplateHelpers.files_from(page, "/posts", index: true) |> Enum.count()

    assert ["Welcome to Your New Fryse Website", "Second Post"] =
             TemplateHelpers.files_from(page, "/posts", sort: "order|asc")
             |> Enum.map(fn file -> file.document.frontmatter.title end)

    assert ["Second Post", "Welcome to Your New Fryse Website"] =
             TemplateHelpers.files_from(page, "/posts", sort: "order|desc")
             |> Enum.map(fn file -> file.document.frontmatter.title end)

    assert 1 = TemplateHelpers.files_from(page, "/posts", offset: 1) |> Enum.count()
    assert 1 = TemplateHelpers.files_from(page, "/posts", limit: 1) |> Enum.count()
  end

  test "frontmatter/1 returns the frontmatter based on various input structs" do
    file = %FryseFile{
      document: %Document{
        frontmatter: %{
          title: "The Title"
        }
      }
    }

    assert %{title: "The Title"} = TemplateHelpers.frontmatter(file)
    assert %{title: "The Title"} = TemplateHelpers.frontmatter(file.document)
  end

  test "frontmatter/2 returns the frontmatter key value or nil" do
    file = %FryseFile{
      document: %Document{
        frontmatter: %{
          title: "The Title"
        }
      }
    }

    # Testing various input formats
    assert "The Title" = TemplateHelpers.frontmatter(file, "title")
    assert "The Title" = TemplateHelpers.frontmatter(file, 'title')
    assert "The Title" = TemplateHelpers.frontmatter(file, :title)
    assert "The Title" = TemplateHelpers.frontmatter(file.document, "title")
    assert "The Title" = TemplateHelpers.frontmatter(file.document, 'title')
    assert "The Title" = TemplateHelpers.frontmatter(file.document, :title)
    assert "The Title" = TemplateHelpers.frontmatter(file.document.frontmatter, "title")
    assert "The Title" = TemplateHelpers.frontmatter(file.document.frontmatter, 'title')
    assert "The Title" = TemplateHelpers.frontmatter(file.document.frontmatter, :title)

    assert nil == TemplateHelpers.frontmatter(file, :excerpt)
  end

  test "frontmatter/3 returns the frontmatter key value or the given default" do
    file = %FryseFile{
      document: %Document{
        frontmatter: %{
          title: "The Title"
        }
      }
    }

    assert "The Title" = TemplateHelpers.frontmatter(file, "title", "")
    assert "" = TemplateHelpers.frontmatter(file, "excerpt", "")
  end

  test "is_active/2 returns if the given source file path is active", %{fryse: fryse} do
    page = %Page{
      fryse: fryse,
      url: "/posts/your-new-fryse-blog.html"
    }

    assert true == TemplateHelpers.is_active(page, "/posts/your-new-fryse-blog.md")
    assert true == TemplateHelpers.is_active(page, '/posts/your-new-fryse-blog.md')
    assert false == TemplateHelpers.is_active(page, "/")
  end

  test "is_active/3 and is_active/4 return custom values for active and inactive", %{fryse: fryse} do
    page = %Page{
      fryse: fryse,
      url: "/posts/your-new-fryse-blog.html"
    }

    assert :active == TemplateHelpers.is_active(page, "/posts/your-new-fryse-blog.md", :active)
    assert :inactive == TemplateHelpers.is_active(page, "/", :active, :inactive)
  end

  test "link_to/2 returns the link to the given Page, File or source file path", %{fryse: fryse} do
    file = %FryseFile{
      path: "content/posts/your-new-fryse-blog.md"
    }

    page = %Page{
      fryse: fryse,
      file: file
    }

    assert "/posts/your-new-fryse-blog.html" = TemplateHelpers.link_to(page, page)
    assert "/posts/your-new-fryse-blog.html" = TemplateHelpers.link_to(page, file)

    assert "/posts/your-new-fryse-blog.html" =
             TemplateHelpers.link_to(page, "content/posts/your-new-fryse-blog.md")
  end
end
