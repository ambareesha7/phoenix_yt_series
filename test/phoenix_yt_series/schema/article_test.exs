defmodule PhoenixYtSeries.Schema.ArticleTest do
  use PhoenixYtSeries.DataCase
  alias PhoenixYtSeries.News.Article

  @expected_field_types %{
    id: :binary_id,
    title: :string,
    body: :string,
    inserted_at: :utc_datetime,
    updated_at: :utc_datetime
  }
  @valid_attrs %{
    "body" => "some body",
    "title" => "some title"
  }

  describe "article schema" do
    test "test for field types" do
      actula_types =
        for field <- Article.__schema__(:fields), into: %{} do
          type = Article.__schema__(:type, field)
          {field, type}
        end

      assert actula_types == @expected_field_types
    end

    test "changeset/2 success with valid attrs" do
      changeset = Article.changeset(%Article{}, @valid_attrs)

      assert %Ecto.Changeset{valid?: true, changes: changes} = changeset

      assert changes == %{
               body: "some body",
               title: "some title"
             }
    end

    test "changeset/2 failure with invalid attrs" do
      changeset = Article.changeset(%Article{}, %{})

      assert %Ecto.Changeset{valid?: false} = changeset

      assert changeset.errors == [
               title: {"can't be blank", [validation: :required]},
               body: {"can't be blank", [validation: :required]}
             ]
    end
  end
end
