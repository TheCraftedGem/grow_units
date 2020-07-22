defmodule MyConfigModule do
  use Goth.Config

  def init(config) do
    {:ok, Keyword.put(config, :json, File.read!(System.get_env("GOOGLE_APPLICATION_CREDENTIALS")))}
  end
end
