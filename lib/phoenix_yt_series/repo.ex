defmodule PhoenixYtSeries.Repo do
  use Ecto.Repo,
    otp_app: :phoenix_yt_series,
    adapter: Ecto.Adapters.SQLite3
end
