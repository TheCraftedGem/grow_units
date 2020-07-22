defmodule GrowUnits.Endpoint do
  use Plug.Router
  # This module is a Plug, that also implements it's own plug pipeline, below:

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)
  # responsible for matching routes

  plug(:fetch_query_params)
  plug(:match)
  # Using Poison for JSON decoding
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  # plug(Plug.Parsers, parsers: [:json, :urlencoded], json_decoder: Jason)
  # responsible for dispatching responses
  plug(:dispatch)

  get "/api/v1/date" do
    IO.inspect(conn.query_string)
    send_resp(conn, 200, GrowUnits.get_coag_data(conn.params))
  end
end
