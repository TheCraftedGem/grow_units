defmodule GrowUnitsTest do
  use ExUnit.Case
  doctest GrowUnits

  test "can make successful request to coagnet" do
    assert GrowUnits.get_stats() == 200
  end
end
