defmodule Fryse.TestCase do
  use ExUnit.CaseTemplate

  alias Fryse.{
    Document,
    Folder,
    Page
  }

  alias Fryse.File, as: FryseFile

  using do
    quote do
      alias Fryse.{
        Document,
        Folder,
        Page
      }

      alias Fryse.File, as: FryseFile
      import unquote(__MODULE__), only: [create_fryse: 0]
    end
  end

  setup do
    {:ok, fryse: create_fryse()}
  end

  def create_fryse() do
    %Fryse{
      config: %{
        name: "Fryse Test Page",
        description: "Fryse Page for ExUnit Tests",
        clean_urls: false,
        theme: "default",
        files: [
          %{from: "css", to: "assets/css"},
          %{from: "js", to: "assets/js"},
          %{from: "images", to: "assets/img"}
        ],
        paginations: [
          %{
            name: "posts",
            from_folder: "posts",
            size: 1,
            sort: "order|desc",
            path: "/posts/:page",
            list_template: "/posts.html.eex",
            first_page: "/posts.html.eex"
          }
        ]
      },
      data: %{
        authors: %{
          fryse: %{
            name: "Fryse",
            description: "Static Site Generator written in Elixir",
            image: "https://avatars3.githubusercontent.com/u/35665539?s=200&v=4"
          }
        }
      },
      content: %Folder{
        name: "content",
        path: "content",
        children: [
          %FryseFile{
            name: "posts",
            path: "content/posts.html.eex",
            excluded: false,
            document: %Document{
              frontmatter: %{title: "Posts"},
              content: """

              <% posts = files_from(@page, "/posts", sort: "order|desc") %>

              <%= for post <- posts do %>
                <% author = FryseDefaultTheme.author(@page, frontmatter(post, "author")) %>

                <h2><a href="<%= link_to(@page, post) %>"><%= frontmatter(post, "title") %></a></h2>
                <small class="text-muted"><%= author.name %>, <%= frontmatter(post, "date") %></small>
                <p><%= frontmatter(post, "excerpt") %></p>
              <% end %>

              <%= if empty?(posts) do %>
                <p>There are no posts yet</p>
              <% end %>
              """
            }
          },
          %Folder{
            name: "posts",
            path: "content/posts",
            children: [
              %FryseFile{
                name: "index",
                path: "content/posts/index.md",
                excluded: false,
                document: %Document{
                  frontmatter: %{
                    title: "Post Index"
                  },
                  content: """
                  <p>Very useful index page.</p>
                  """
                }
              },
              %FryseFile{
                name: "draft-post",
                path: "content/posts/_draft-post.md",
                excluded: true,
                document: %Document{
                  frontmatter: %{
                    author: "fryse",
                    date: "06 February 2018",
                    excerpt: "Not done yet",
                    layout: "post",
                    order: "2018-02-06-12-00",
                    title: "Draft Post"
                  },
                  content: """
                  <p>WiP</p>
                  """
                }
              },
              %FryseFile{
                name: "second-post",
                path: "content/posts/second-post.md",
                excluded: false,
                document: %Document{
                  frontmatter: %{
                    author: "fryse",
                    date: "05 February 2018",
                    excerpt: "Just because.",
                    layout: "post",
                    order: "2018-02-05-12-47",
                    title: "Second Post"
                  },
                  content: """
                  <p>Just to have some content.</p>
                  """
                }
              },
              %FryseFile{
                name: "your-new-fryse-blog",
                path: "content/posts/your-new-fryse-blog.md",
                excluded: false,
                document: %Document{
                  frontmatter: %{
                    author: "fryse",
                    date: "05 February 2018",
                    excerpt: "This is the first post on your new Fryse website.",
                    layout: "post",
                    order: "2018-02-05-12-45",
                    title: "Welcome to Your New Fryse Website"
                  },
                  content: """
                  <p>This is the first post on your new Fryse website.
                  You can use Markdown, HTML, or Embedded Elixir (EEx) Templates.</p>
                  """
                }
              }
            ]
          },
          %FryseFile{
            name: "index",
            path: "content/index.html.eex",
            excluded: false,
            document: %Document{
              frontmatter: %{layout: "home", title: "Home"},
              content: """
              <!-- This file does not need any content because the selected layout will do the work for us -->
              """
            }
          }
        ]
      }
    }
  end
end
