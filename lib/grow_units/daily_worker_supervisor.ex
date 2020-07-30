defmodule GrowUnits.DailyWorker.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end


  @impl true
  def init(_init_arg) do
    children = [
      {GrowUnits.DailyWorker, [starting_state: []]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end


defmodule GrowUnits.DailyWorker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts[:starting_state], name: __MODULE__)
  end

  @impl true
  def init(stack) do

    {:ok, stack, {:continue, :start_timer}}
  end


  @impl true
  def handle_continue(:start_timer, state) do

    # Start timer here
    {:noreply, state}
  end
end
