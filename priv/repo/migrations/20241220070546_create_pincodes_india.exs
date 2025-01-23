defmodule PhoenixYtSeries.Repo.Migrations.CreatePincodesIndia do
  use Ecto.Migration

  def change do
    create table(:pincodes_india, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :circle_name, :string
      add :region_name, :string
      add :division_name, :string
      add :office_name, :string
      add :pincode, :string
      add :office_type, :string
      add :delivery, :string
      add :district, :string
      add :state_name, :string
      add :latitude, :string
      add :longitude, :string

      timestamps(type: :utc_datetime)
    end

    create index(:pincodes_india, [:pincode, :office_name])
  end
end
