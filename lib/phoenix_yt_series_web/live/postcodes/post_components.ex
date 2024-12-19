defmodule PhoenixYtSeriesWeb.Live.PostComponents do
  use Phoenix.Component
  import PhoenixYtSeriesWeb.CoreComponents

  def pincode_uploads(assigns) do
    ~H"""
    <form class="" id="upload-form" phx-submit="save" phx-change="validate">
      <.live_file_input upload={@uploads.avatar} />
      <.button
        :if={
          length(@uploads.avatar.entries) != 0 && List.first(@uploads.avatar.entries).progress == 100
        }
        type="submit"
      >
        Upload
      </.button>
    </form>
    <%!-- use phx-drop-target with the upload ref to enable file drag and drop --%>
    <section phx-drop-target={@uploads.avatar.ref}>
      <%!-- render each avatar entry --%>
      <article :for={entry <- @uploads.avatar.entries} class="upload-entry">
        <%!-- entry.progress will update automatically for in-flight entries --%>
        <progress value={entry.progress} max="100">{entry.progress}%</progress>
        <%!-- a regular click event whose handler will invoke Phoenix.LiveView.cancel_upload/3 --%>
        <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref} aria-label="cancel">
          &times;
        </button>
        <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
        <p :for={err <- upload_errors(@uploads.avatar, entry)} class="text-red-500">
          {error_to_string(err)}
        </p>
      </article>
      <%!-- Phoenix.Component.upload_errors/1 returns a list of error atoms --%>
      <p :for={err <- upload_errors(@uploads.avatar)} class="text-red-500">{error_to_string(err)}</p>
    </section>
    """
  end

  defp error_to_string(:too_large), do: "File size is too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
