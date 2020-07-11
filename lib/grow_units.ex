defmodule GrowUnits do
  use Tesla

  # plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  # plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  # plug Tesla.Middleware.JSON

  def get_stats() do
    {:ok, response} = get("https://coagmet.colostate.edu/rawdata_results.php?station=FTC01&start_date=2020-07-10&end_date=2020-07-10&daily=1&qc=1&etr=1")
    # Jason.encode(response.body)
    response.body
  end
end
