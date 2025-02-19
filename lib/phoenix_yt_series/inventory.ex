defmodule PhoenixYtSeries.Inventory do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get_state do
    Agent.get(__MODULE__, fn state -> state end)
  end

  def get_state(key) do
    Agent.get(__MODULE__, fn state -> Map.get(state, key) end)
  end

  def check_and_update_state(key, quantity) when quantity <= 100 do
    case get_state(key) do
      nil ->
        add_new(key, quantity)

      qty when qty + quantity <= 100 ->
        update_state(key, quantity)

      qty ->
        IO.puts(
          "We have #{key} quantity of #{qty}, Total exceeds by #{qty + quantity - 100}, Max limit is 100"
        )
    end
  end

  def check_and_update_state(_key, quantity) when quantity >= 101 do
    IO.puts("Quantity can't be more than 100")
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
          IO.puts("Quantity can't be removed")
          val
        end
      end)
    end)

    get_state()
  end
end
