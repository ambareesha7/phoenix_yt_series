defmodule PhoenixYtSeries.InventoryAgentTest do
  alias PhoenixYtSeries.InventoryAgent
  use ExUnit.Case

  setup do
    {:ok, pid} = InventoryAgent.start_link([])

    on_exit(fn ->
      if Process.alive?(pid) do
        Agent.stop(pid)
      end
    end)

    %{pid: pid}
  end

  describe "InventoryAgent" do
    test "InventoryAgent is alive?", %{pid: pid} do
      # assert {:ok, pid} = InventoryAgent.start_link([])
      assert Process.alive?(pid)
    end

    test "add new inventory" do
      InventoryAgent.check_and_update_state(:tomoto, 40)
      state = InventoryAgent.check_and_update_state(:tomoto, 20)
      assert state.tomoto == 60, "added tomoto total are wrong"
    end

    test "remove added inventory item" do
      state = InventoryAgent.check_and_update_state(:pease, 50)
      assert state.pease == 50
      InventoryAgent.delete(:pease)
      InventoryAgent.get_state_by_key(:pease)
      assert nil == InventoryAgent.get_state_by_key(:pease)
    end

    test "update added inventory item" do
      quantity = 50
      reduced_quantity = 20

      assert InventoryAgent.check_and_update_state(:nuts, quantity).nuts == quantity

      assert quantity - reduced_quantity == InventoryAgent.reduce_quantity(:nuts, 20).nuts
    end

    test "reject overloading inventory value", %{pid: _pid} do
      quantity = 90

      assert InventoryAgent.check_and_update_state(:orange, quantity).orange == quantity

      assert {:error, "Max limit is 100"} =
               InventoryAgent.check_and_update_state(:orange, quantity)

      assert {:error, "Max limit is 100"} = InventoryAgent.check_and_update_state(:apple, 130)
    end

    test "reject reducing of excess inventory valume more then current", %{pid: _pid} do
      quantity = 40

      assert InventoryAgent.check_and_update_state(:mango, quantity).mango == quantity

      new_state = InventoryAgent.reduce_quantity(:mango, 60)

      assert new_state.mango == quantity
    end
  end
end
