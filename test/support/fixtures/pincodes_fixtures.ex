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
      |> Enum.into(%{
        circle_name: "some circle_name"
      })
      |> PhoenixYtSeries.Pincodes.create_pincode_india()

    pincode_india
  end
end
