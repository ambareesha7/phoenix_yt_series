defmodule PhoenixYtSeries.Counter do
  use GenServer
  require Logger
  alias Phoenix.PubSub

  @topic "counter_updates"

  # Public API

  def start_link(_) do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def increment do
    GenServer.call(__MODULE__, :increment)
  end

  def get_value do
    GenServer.call(__MODULE__, :get_value)
  end

  # GenServer Callbacks

  def init(initial_value) do
    {:ok, initial_value}
  end

  def handle_call(:increment, _from, state) do
    new_state = state + 1
    Logger.info("Incrementing counter to #{new_state}")

    PubSub.broadcast(PhoenixYtSeries.PubSub, @topic, {:new_count, new_state})
    {:reply, new_state, new_state}
  end

  def handle_call(:get_value, _from, state) do
    {:reply, state, state}
  end
end
