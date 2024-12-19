defmodule PhoenixYtSeriesWeb.Live.Postcode do
  use PhoenixYtSeriesWeb, :live_view
  import PhoenixYtSeriesWeb.Live.PostComponents

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, get_page_title(__MODULE__))
     |> assign(uploaded_files: [], show_upload: false)
     |> allow_upload(:avatar,
       auto_upload: true,
       accept: ~w(.csv),
       max_entries: 1,
       max_file_size: 35_000_000
     )}
  end

  def handle_event("uploaded", params, socket) do
    {:noreply, assign(socket, :show_upload, params["uploaded"])}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("save", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        file_name = "#{Path.basename(entry.client_name)}"
        dir = Path.join(["priv", "static", "uploads"])
        # You will need to create `priv/static/uploads` for `File.cp!/2` to work.
        File.mkdir_p!(dir)
        File.cp!(path, Path.join(Application.app_dir(:phoenix_yt_series, dir), file_name))
        {:ok, file_name}
      end)

    {:noreply,
     socket
     |> update(:uploaded_files, &(&1 ++ uploaded_files))
     |> assign(:show_upload, false)}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end
end
