defmodule GrowUnits do
  use Tesla

  def get_coag_data() do
    today =
      DateTime.utc_now()
      |> parse_date()

    {:ok, rfd01} =
      get(
        "https://coagmet.colostate.edu/rawdata_results.php?station=RFD01&start_date=2020-01-01&end_date=#{
          today
        }&daily=1&qc=1&etr=1"
      )

    {:ok, oth01} =
      get(
        "https://coagmet.colostate.edu/rawdata_results.php?station=OTH011&start_date=2020-01-01&end_date=#{
          today
        }&daily=1&qc=1&etr=1"
      )

    {:ok, ctr01} =
      get(
        "https://coagmet.colostate.edu/rawdata_results.php?station=CTR01&start_date=2020-01-01&end_date=#{
          today
        }&daily=1&qc=1&etr=1"
      )

    rfd01_body = rfd01.body
    oth01_body = oth01.body
    ctr01_body = ctr01.body
    coag_parse(ctr01_body, oth01_body, rfd01_body)
  end

  def parse_date(date) do
    [year, month, day] = [date.year, date.month, date.day]

    cond do
      month < 10 && day > 9 -> "#{year}-0#{month}-#{day}"
      month < 10 && day < 10 -> "#{year}-0#{month}-0#{day}"
      month > 9 && day < 10 -> "#{year}-#{month}-0#{day}"
      month > 9 && day > 9 -> "#{year}-#{month}-#{day}"
    end
  end

  def sheets_client do
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/spreadsheets")

    sheet_address =
      "https://sheets.googleapis.com/v4/spreadsheets/1i7w9RP-Y-1Ug6hKVxX8jL80x43VfbUo3ZJxR6sEzh4Y/values/Sheet1"

    middleware = [
      {Tesla.Middleware.Headers, [{"authorization", "Bearer " <> token.token}]}
    ]

    Tesla.client(middleware)
    |> get(sheet_address)
  end

  def coag_parse(response) when is_binary(response) do
    response
    |> String.split("\n", trim: true)
    |> Enum.map(fn x -> x |> String.split(",") end)
  end

  def coag_parse(response) when is_list(response) do
   x =  response
    |> Enum.map(fn station_data ->

      station =
        station_data
        |> Enum.map(&parse_station_data/1)

      date =
        station_data
        |> Enum.map(&parse_date_data/1)

      max_temp =
        station_data
        |> Enum.map(&parse_max_temp_data/1)

      min_temp =
        station_data
        |> Enum.map(&parse_min_temp_data/1)

      parsed_response = %{
        station: station,
        date: date,
        growing_degree_units: generate_growing_degree_units(min_temp, max_temp)
      }

      Jason.encode(parsed_response)
    end)
 require IEx; IEx.pry
  end

  def coag_parse([first_station_data, second_station_data, third_station_data]) do
    first_station_data = first_station_data
    |> Enum.map(&coag_parse/1)
    second_station_data = second_station_data
    |> Enum.map(&coag_parse/1)
    third_station_data = third_station_data
    |> Enum.map(&coag_parse/1)
  end

  def coag_parse(first_station, second_station, third_station) do
    first_station_response =
      first_station
      |> coag_parse()

    second_station_response =
      second_station
      |> coag_parse()

    third_station_respone =
      third_station
      |> coag_parse()

    coag_parse([first_station_response, second_station_response, third_station_respone])
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

    gdu = (max_temp + min_temp) / 2 - 50

    gdu
    |> Float.round(2)
  end

  def adjust_for_max_temp_threshold(max_temp) when max_temp > 86, do: 86
  def adjust_for_max_temp_threshold(max_temp), do: max_temp
  def adjust_for_min_temp_threshold(min_temp) when min_temp < 50, do: 50
  def adjust_for_min_temp_threshold(min_temp), do: min_temp
end
