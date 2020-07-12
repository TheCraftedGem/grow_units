defmodule GrowUnits.Plug do
  import Plug.Conn

  def init(options), do: options
  def call(conn, _opts), do: conn
end
