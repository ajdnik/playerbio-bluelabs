defmodule PlayerBioGeneratorTest do
  use ExUnit.Case
  doctest PlayerBio.Generator

  test "generates a map" do
    assert is_map(PlayerBio.Generator.new())
  end
end
