defmodule GrowUnits do
  use Tesla
  # plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  # plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  plug(Tesla.Middleware.JSON)

  def get_coag_data(_date) do
    {:ok, response} =
      get(
        "https://coagmet.colostate.edu/rawdata_results.php?station=FTC01&start_date=2020-07-10&end_date=2020-07-10&daily=1&qc=1&etr=1"
      )

    response.body
  end

  ## TODO Figure out where to include field name
  # webhook for google drive https://developers.google.com/drive/api/v3/push
  # docs for reading and writing to sheets api https://developers.google.com/sheets/api/guides/concepts

  def get_field_name_and_water_date() do
    # phase 1
    # get field names and water dates
      # What's the best way?
    # load field names and water dates into maps
    # Group fields by water date
      # %{
        #  date: 2020/04/17,
        #  fields: [%{field_name: "Some Field name", water_date: 2020/12/09}]
      #  }
    # Iterate through water dates
    # Generate GDU for date
      # return field name and GDU for each field
    # generate report
    # send report to be merged

    #concerns
      # Will Field Names Always be uniq?

    #phase 2
    # setup worker
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

    parsed_response
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

  # def generate_csv(csv_data) do

  # end
end
