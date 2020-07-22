defmodule GrowUnits do
  use Tesla

  def get_coag_data(params) do
    date = params["date"]

    {:ok, response} =
      get(
        "https://coagmet.colostate.edu/rawdata_results.php?station=FTC01&start_date=#{date}&end_date=#{date}&daily=1&qc=1&etr=1"
      )

  {:ok, body} =  response.body
    |> coag_parse()
    body
  end

  def sheets_client do
    {:ok, token} =  Goth.Token.for_scope("https://www.googleapis.com/auth/spreadsheets")
    sheet_address =  "https://sheets.googleapis.com/v4/spreadsheets/1i7w9RP-Y-1Ug6hKVxX8jL80x43VfbUo3ZJxR6sEzh4Y/values/range=A1:B2"

    middleware = [
      {Tesla.Middleware.Headers, [{"authorization", "Bearer " <> token.token }]}
    ]

    Tesla.client(middleware)
    |> get(sheet_address)
  end

  def coag_parse(response) do
    response =
      response
      |> String.split(",")

    station =
      response
      |> parse_station_data()

    date =
      response
      |> parse_date_data()

    max_temp =
      response
      |> parse_max_temp_data()

    min_temp =
      response
      |> parse_min_temp_data()

    parsed_response = %{
      station: station,
      date: date,
      max_temp: max_temp,
      min_temp: min_temp,
      growing_degree_units: generate_growing_degree_units(min_temp, max_temp)
    }

    Jason.encode(parsed_response)
  end

  def parse_station_data(response) do
    response
    |> Enum.at(0)
  end

  def parse_date_data(response) do
    response
    |> Enum.at(1)
  end

  def parse_max_temp_data(response) do
    {temp, _} =
      response
      |> Enum.at(3)
      |> Float.parse()

    temp
    |> convert_celsius_to_fahrenheit()
  end

  def parse_min_temp_data(response) do
    {temp, _} =
      response
      |> Enum.at(5)
      |> Float.parse()

    temp
    |> convert_celsius_to_fahrenheit()
  end

  def convert_celsius_to_fahrenheit(cels_temp) do
    (cels_temp * 1.8 + 32)
    |> Float.round(2)
  end

  def generate_growing_degree_units(min_temp, max_temp) do
    max_temp = adjust_for_max_temp_threshold(max_temp)
    min_temp = adjust_for_min_temp_threshold(min_temp)

    gdu = ((max_temp + min_temp) / 2) - 50

    gdu
    |> Float.round(2)
  end

  def adjust_for_max_temp_threshold(max_temp) when max_temp > 86, do: 86
  def adjust_for_max_temp_threshold(max_temp), do: max_temp
  def adjust_for_min_temp_threshold(min_temp) when min_temp < 50, do: 50
  def adjust_for_min_temp_threshold(min_temp), do: min_temp
end
