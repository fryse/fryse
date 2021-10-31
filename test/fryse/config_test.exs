defmodule Fryse.ConfigTest do
  use ExUnit.Case, async: true
  alias Fryse.Config
  alias Fryse.Errors.MissingConfigValue
  alias Fryse.Errors.InvalidConfigValue

  describe "merge/2" do
    test "original and default values are merged" do
      original = %{foo: "one", bar: "two"}
      default = %{baz: "three"}
      assert %{foo: "one", bar: "two", baz: "three"} = Config.merge(original, default)
    end
    test "original values are not overridden by default values" do
      original = %{foo: "one", bar: "two"}
      default = %{baz: "three", foo: "four"}
      assert %{foo: "one", bar: "two", baz: "three"} = Config.merge(original, default)
    end
  end

  describe "override/2" do
    test "original and override values are merged" do
      original = %{foo: "one", bar: "two"}
      override = %{baz: "three"}
      assert %{foo: "one", bar: "two", baz: "three"} = Config.override(original, override)
    end
    test "original values are overridden by override values" do
      original = %{foo: "one", bar: "two"}
      override = %{baz: "three", foo: "four"}
      assert %{foo: "four", bar: "two", baz: "three"} = Config.override(original, override)
    end
  end

  describe "validate :theme key" do
    test "the key must be not nil" do
      assert %MissingConfigValue{key: :theme} = Config.validate_key(:theme, nil)
      assert %MissingConfigValue{key: :theme} = Config.validate_key(:theme, "")
      assert :ok = Config.validate_key(:theme, "default")
    end
  end

  describe "validate :files key" do
    test "the key must be nil or a list" do
      assert :ok = Config.validate_key(:files, nil)
      assert :ok = Config.validate_key(:files, [])
      assert %InvalidConfigValue{key: :files} = Config.validate_key(:files, 1)
      assert %InvalidConfigValue{key: :files} = Config.validate_key(:files, true)
      assert %InvalidConfigValue{key: :files} = Config.validate_key(:files, "hello")
    end

    test "the items must have from and to keys which are not empty" do
      assert :ok = Config.validate_key(:files, [%{from: "/", to: "/"}])
      assert %InvalidConfigValue{key: :files} = Config.validate_key(:files, [%{from: "", to: ""}])
      assert %InvalidConfigValue{key: :files} = Config.validate_key(:files, [%{from: nil, to: "/"}])
    end
  end

  describe "validate :paginations key" do
    test "the key must be not nil" do
      assert %MissingConfigValue{key: :paginations} = Config.validate_key(:paginations, nil)
      assert %MissingConfigValue{key: :paginations} = Config.validate_key(:paginations, "")
      assert :ok = Config.validate_key(:paginations, [])
    end

    test "the key must be a list" do
      assert :ok = Config.validate_key(:paginations, [])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, 1)
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, true)
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, "hello")
    end

    test "the items must contain all keys and they must have the right value type" do
      valid_item = %{
        name: "posts",
        from_folder: "posts",
        size: 1,
        sort: "order|desc",
        path: "/posts/:page",
        list_template: "/posts/index.html.eex",
        first_page: "index.html.eex",
      }

      assert :ok = Config.validate_key(:paginations, [valid_item])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [Map.delete(valid_item, :name)])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [Map.delete(valid_item, :from_folder)])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [Map.delete(valid_item, :size)])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [Map.delete(valid_item, :sort)])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [Map.delete(valid_item, :path)])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [Map.delete(valid_item, :list_template)])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [Map.delete(valid_item, :first_page)])

      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | name: nil}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | name: ""}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | name: 0}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | name: true}])

      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | from_folder: nil}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | from_folder: ""}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | from_folder: 0}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | from_folder: true}])

      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | size: nil}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | size: ""}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | size: 0}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | size: -1}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | size: true}])

      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | sort: nil}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | sort: ""}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | sort: 0}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | sort: true}])

      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | path: nil}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | path: ""}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | path: 0}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | path: true}])

      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | list_template: nil}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | list_template: ""}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | list_template: 0}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | list_template: true}])

      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | first_page: nil}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | first_page: ""}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | first_page: 0}])
      assert %InvalidConfigValue{key: :paginations} = Config.validate_key(:paginations, [%{valid_item | first_page: true}])
    end
  end

  describe "validate :clean_urls key" do
    test "the key must be a boolean" do
      assert :ok = Config.validate_key(:clean_urls, true)
      assert :ok = Config.validate_key(:clean_urls, false)
      assert %InvalidConfigValue{key: :clean_urls} = Config.validate_key(:clean_urls, 1)
      assert %InvalidConfigValue{key: :clean_urls} = Config.validate_key(:clean_urls, 0)
      assert %InvalidConfigValue{key: :clean_urls} = Config.validate_key(:clean_urls, "")
      assert %InvalidConfigValue{key: :clean_urls} = Config.validate_key(:clean_urls, "test")
      assert %InvalidConfigValue{key: :clean_urls} = Config.validate_key(:clean_urls, nil)
    end
  end
end
