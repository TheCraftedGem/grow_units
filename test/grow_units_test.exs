defmodule GrowUnitsTest do
  use ExUnit.Case
  doctest GrowUnits

  response = [
      "ftc01",
      "2020-07-10",
      "26.09",
      "37.26",
      "16:10:00",
      "14.34",
      "04:21:20",
      "0.985",
      "0.832",
      "01:27:30",
      "0.001",
      "09:47:30",
      "30.64",
      "160.8",
      "0",
      "29.77",
      "15:39:10",
      "19.84",
      "06:25:00",
      "25.87",
      "18:39:40",
      "21.13",
      "08:18:30",
      "12.68",
      "",
      "12.35",
      "16:57:00",
      "311.9",
      "10.5273",
      "10.0052",
      "10.1175\n"
    ]


  test "can make successful request to coagnet" do
    expected =
      GrowUnits.get_coag_data()
      |> GrowUnits.coag_parse()

    assert expected[:station] == "ftc01"
  end

  test "can convert celsius to Fahrenheit" do
    assert GrowUnits.convert_celsius_to_fahrenheit(20) == 68.00
  end

  test "can adjust max_temp for gdu" do
    assert GrowUnits.generate_growing_degree_units(10, 100) == 68.00
  end


end
