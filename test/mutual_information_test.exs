defmodule MutualInformationTest do
  use ExUnit.Case
  doctest MutualInformation

  test "calculates correct values" do
    assert MutualInformation.compute([1, 2, 3, 4, 5], [1, 2, 3, 4, 5]) > MutualInformation.compute([1, 2, 3, 4, 5], [0, 0, 3, 4, 5])
  end
end
