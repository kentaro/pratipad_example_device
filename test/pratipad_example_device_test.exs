defmodule PratipadExampleDeviceTest do
  use ExUnit.Case
  doctest PratipadExampleDevice

  test "greets the world" do
    assert PratipadExampleDevice.hello() == :world
  end
end
