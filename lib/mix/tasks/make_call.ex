defmodule Mix.Tasks.MakeCall do
  use Mix.Task


  def run(_) do
    Mix.Task.run("app.start")

    GrowUnits.sheets_client()
  end
end
