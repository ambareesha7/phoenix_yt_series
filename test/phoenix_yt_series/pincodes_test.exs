defmodule PhoenixYtSeries.PincodesTest do
  use PhoenixYtSeries.DataCase

  alias PhoenixYtSeries.Pincodes

  describe "pincodes_india" do
    alias PhoenixYtSeries.Pincodes.PincodeIndia

    import PhoenixYtSeries.PincodesFixtures

    @invalid_attrs %{circle_name: nil}

    test "list_pincodes_india/0 returns all pincodes_india" do
      pincode_india = pincode_india_fixture()
      assert Pincodes.list_pincodes_india() == [pincode_india]
    end

    test "get_pincode_india!/1 returns the pincode_india with given id" do
      pincode_india = pincode_india_fixture()
      assert Pincodes.get_pincode_india!(pincode_india.id) == pincode_india
    end

    test "create_pincode_india/1 with valid data creates a pincode_india" do
      valid_attrs = %{circle_name: "some circle_name"}

      assert {:ok, %PincodeIndia{} = pincode_india} = Pincodes.create_pincode_india(valid_attrs)
      assert pincode_india.circle_name == "some circle_name"
    end

    test "create_pincode_india/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pincodes.create_pincode_india(@invalid_attrs)
    end

    test "update_pincode_india/2 with valid data updates the pincode_india" do
      pincode_india = pincode_india_fixture()
      update_attrs = %{circle_name: "some updated circle_name"}

      assert {:ok, %PincodeIndia{} = pincode_india} = Pincodes.update_pincode_india(pincode_india, update_attrs)
      assert pincode_india.circle_name == "some updated circle_name"
    end

    test "update_pincode_india/2 with invalid data returns error changeset" do
      pincode_india = pincode_india_fixture()
      assert {:error, %Ecto.Changeset{}} = Pincodes.update_pincode_india(pincode_india, @invalid_attrs)
      assert pincode_india == Pincodes.get_pincode_india!(pincode_india.id)
    end

    test "delete_pincode_india/1 deletes the pincode_india" do
      pincode_india = pincode_india_fixture()
      assert {:ok, %PincodeIndia{}} = Pincodes.delete_pincode_india(pincode_india)
      assert_raise Ecto.NoResultsError, fn -> Pincodes.get_pincode_india!(pincode_india.id) end
    end

    test "change_pincode_india/1 returns a pincode_india changeset" do
      pincode_india = pincode_india_fixture()
      assert %Ecto.Changeset{} = Pincodes.change_pincode_india(pincode_india)
    end
  end
end
