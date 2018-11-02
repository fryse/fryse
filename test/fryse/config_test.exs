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
end
