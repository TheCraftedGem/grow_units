defmodule GrowUnits do
  use Tesla

  # plug Tesla.Middleware.BaseUrl, "https://api.github.com"
  # plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]
  # plug Tesla.Middleware.JSON

  def get_stats() do
    {:ok, response} = get("https://github.com/teamon/tesla")
    response.status
  end
end
