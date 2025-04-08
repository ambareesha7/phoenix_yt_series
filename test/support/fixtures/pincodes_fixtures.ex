defmodule PhoenixYtSeries.PincodesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhoenixYtSeries.Pincodes` context.
  """

  @doc """
  Generate a pincode_india.
  """
  def pincode_india_fixture(attrs \\ %{}) do
    {:ok, pincode_india} =
      attrs
      |> Enum.into(pincode_valid_attr())
      |> PhoenixYtSeries.Pincodes.create_pincode_india()

    pincode_india
  end

  def pincode_valid_attr do
    %{
      circle_name: "some circle_name",
      region_name: "region_name",
      division_name: "division_name",
      office_name: "office_name",
      pincode: "pincode",
      office_type: "office_type",
      delivery: "delivery",
      district: "district",
      state_name: "state_name",
      latitude: "latitude",
      longitude: "longitude"
    }
  end
end
