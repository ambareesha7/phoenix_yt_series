defmodule PhoenixYtSeries.Pincodes do
  @moduledoc """
  The Pincodes context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias PhoenixYtSeries.Repo

  alias PhoenixYtSeries.Pincodes.PincodeIndia

  def parse_csv(path) do
    headers =
      path
      |> File.stream!()
      |> CSV.decode!()
      |> Enum.take(1)
      |> List.first()
      |> Enum.map(fn str -> to_snakecase(str) end)

    list =
      path
      |> File.stream!()
      |> CSV.decode!(headers: headers)
      |> Enum.to_list()
      |> List.delete_at(0)
      |> Enum.map(fn f ->
        Map.merge(f, %{
          inserted_at: %{DateTime.utc_now() | microsecond: {0, 0}},
          updated_at: %{DateTime.utc_now() | microsecond: {0, 0}}
        })
      end)

    Task.start(fn ->
      parse_list(list)
    end)
  end

  def parse_list(list) do
    divisor = 100
    chunk_size = div(length(list), divisor)

    Enum.reduce(0..divisor, 0, fn _x, acc ->
      insert_all(Enum.slice(list, acc, chunk_size))
      acc + chunk_size
    end)
  end

  def insert_all(list) do
    Repo.insert_all(
      {"pincodes_india", PincodeIndia},
      list,
      log: false,
      on_conflict: :nothing
    )
  end

  def delete_all_pincodes do
    Repo.delete_all("pincodes_india")
  end

  defp to_snakecase(string) do
    tail = Regex.replace(~r/[A-Z]/, string, fn match -> "_#{String.downcase(match)}" end)

    String.to_existing_atom(binary_slice(tail, 1..String.length(tail)))
  end

  def get_all_states() do
    PincodeIndia
    |> distinct(true)
    |> order_by(asc: :state_name)
    |> select([p], p.state_name)
    |> Repo.all()
  end

  def get_statewise(state) do
    Repo.query(
      " SELECT id, district, COUNT(pincode) AS pincodes FROM pincodes_india WHERE state_name = $1 GROUP BY district ORDER BY district; ",
      [state]
    )
  end

  def get_district_wise(state, district) when is_nil(state) or is_nil(district) do
    []
  end

  def get_district_wise(state, district) do
    PincodeIndia
    |> where([p], p.state_name == ^state and p.district == ^district)
    |> order_by(asc: :office_name)
    |> Repo.all()
  end

  def get_pincode_wise(picode) do
    PincodeIndia
    |> distinct(true)
    |> where([p], p.pincode == ^picode)
    |> order_by(asc: :district)
    |> Repo.all()
  end

  def fetch(filter) do
    PincodeIndia
    |> search(filter)
    |> limit(200)
    |> Repo.all()
  end

  defp search(query, filter) when is_binary(filter) and byte_size(filter) > 0 do
    query
    |> where([m], fragment("? LIKE ('%' || ? || '%')", m.office_name, ^filter))
  end

  defp search(query, _filter), do: query

  @doc """
  Returns the list of pincodes_india.

  ## Examples

      iex> list_pincodes_india()
      [%PincodeIndia{}, ...]

  """
  def list_pincodes_india do
    Repo.all(PincodeIndia)
  end

  @doc """
  Gets a single pincode_india.

  Raises `Ecto.NoResultsError` if the Pincode india does not exist.

  ## Examples

      iex> get_pincode_india!(123)
      %PincodeIndia{}

      iex> get_pincode_india!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pincode_india!(id), do: Repo.get!(PincodeIndia, id)

  @doc """
  Creates a pincode_india.

  ## Examples

      iex> create_pincode_india(%{field: value})
      {:ok, %PincodeIndia{}}

      iex> create_pincode_india(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pincode_india(attrs \\ %{}) do
    %PincodeIndia{}
    |> PincodeIndia.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pincode_india.

  ## Examples

      iex> update_pincode_india(pincode_india, %{field: new_value})
      {:ok, %PincodeIndia{}}

      iex> update_pincode_india(pincode_india, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pincode_india(%PincodeIndia{} = pincode_india, attrs) do
    pincode_india
    |> PincodeIndia.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pincode_india.

  ## Examples

      iex> delete_pincode_india(pincode_india)
      {:ok, %PincodeIndia{}}

      iex> delete_pincode_india(pincode_india)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pincode_india(%PincodeIndia{} = pincode_india) do
    Repo.delete(pincode_india)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pincode_india changes.

  ## Examples

      iex> change_pincode_india(pincode_india)
      %Ecto.Changeset{data: %PincodeIndia{}}

  """
  def change_pincode_india(%PincodeIndia{} = pincode_india, attrs \\ %{}) do
    PincodeIndia.changeset(pincode_india, attrs)
  end
end
