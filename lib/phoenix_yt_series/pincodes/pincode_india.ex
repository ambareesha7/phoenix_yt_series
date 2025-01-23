defmodule PhoenixYtSeries.Pincodes.PincodeIndia do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pincodes_india" do
    field :circle_name, :string
    field :region_name, :string
    field :division_name, :string
    field :office_name, :string
    field :pincode, :string
    field :office_type, :string
    field :delivery, :string
    field :district, :string
    field :state_name, :string
    field :latitude, :string
    field :longitude, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pincode_india, attrs) do
    pincode_india
    |> cast(attrs, get_fields())
    |> validate_required(get_fields())
  end

  def get_fields() do
    __schema__(:fields) -- [:inserted_at, :updated_at]
  end
end
