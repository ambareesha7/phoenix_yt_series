defmodule PhoenixYtSeries.InventoryAgent do
  use Agent
  require Logger

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_state do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def get_state_by_key(key) do
    Agent.get(__MODULE__, fn state -> Map.get(state, key) end)
  end

  def check_and_update_state(key, quantity) when quantity <= 100 do
    case get_state_by_key(key) do
      nil ->
        add_new(key, quantity)

      qty when qty + quantity <= 100 ->
        update_state(key, quantity)

      qty ->
        Logger.info("We have #{key} quantity of #{qty}, Max limit is 100")
        {:error, "Max limit is 100"}
    end
  end

  def check_and_update_state(_key, quantity) when quantity >= 101 do
    Logger.info("Quantity can't be more than 100")
    {:error, "Max limit is 100"}
  end

  defp add_new(key, quantity) do
    Agent.update(__MODULE__, fn state ->
      Map.put(state, key, quantity)
    end)

    get_state()
  end

  defp update_state(key, value) do
    Agent.update(__MODULE__, fn state -> Map.update!(state, key, fn val -> val + value end) end)
    get_state()
  end

  def delete(key) do
    Agent.update(__MODULE__, fn state -> Map.delete(state, key) end)
    get_state()
  end

  def reduce_quantity(key, quantity) do
    Agent.update(__MODULE__, fn state ->
      Map.update!(state, key, fn val ->
        if val >= quantity do
          val - quantity
        else
          Logger.info("Quantity can't be reduced")
          val
        end
      end)
    end)

    get_state()
  end
end
