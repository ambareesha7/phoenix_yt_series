defmodule PhoenixYtSeriesWeb.Live.PostComponents do
  use Phoenix.Component
  import PhoenixYtSeriesWeb.CoreComponents
  alias Phoenix.LiveView.JS

  def build_states_table(assigns) do
    ~H"""
    <h1 class="text-3xl font-bold m-8 text-center">STATE-WISE LISTING OF PIN CODES</h1>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div
        :for={name <- @states}
        id={"state_#{name}"}
        class="bg-white rounded-lg shadow-md p-4 text-center hover:bg-gray-200 transition duration-300"
      >
        <a
          href="#"
          phx-click={JS.push("state", value: %{state: name})}
          class="text-blue-500 font-medium"
        >
          {name}
        </a>
      </div>
    </div>
    """
  end

  def build_district_table(assigns) do
    ~H"""
    <div class="container mx-auto p-8 bg-white rounded-lg shadow-md mt-10">
      <h1 class="text-2xl font-bold mb-6 text-center">DISTRICTS OF {@state}</h1>

      <table class="min-w-full border-collapse border border-gray-300">
        <thead>
          <tr class="">
            <.t_header name="DISTRICT" />
            <.t_header name="TOTAL POST OFFICE" />
          </tr>
        </thead>
        <tbody id="districts_1" phx-update="stream">
          <tr :for={{id, district} <- @districts_pins} id={id}>
            <.t_item name={district.name} is_btn={true} />
            <.t_item name={district.pins} is_btn={false} />
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def build_post_office_table(assigns) do
    ~H"""
    <div class="container mx-auto p-8 bg-white rounded-lg shadow-md mt-10">
      <h1 class="text-2xl font-bold mb-6 text-center">{@name}</h1>
      <table class="min-w-full border-collapse border border-gray-300">
        <thead>
          <tr class="">
            <.t_header name="POST OFFICE" />
            <.t_header name="PINCODE" />
          </tr>
        </thead>
        <tbody id={@stream_id} phx-update="stream">
          <tr :for={{id, post_office} <- @items_list} id={id} class="">
            <.th_btn
              name={post_office.office_name}
              is_btn={true}
              event={@event_name}
              val={%{post_office: Map.from_struct(post_office) |> Map.delete(:__meta__)}}
            />

            <.t_item name={post_office.pincode} is_btn={false} />
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def build_post_office(assigns) do
    ~H"""
    <div class="container mx-auto p-8 bg-white rounded-lg shadow-md mt-10">
      <h1 class="text-2xl font-bold mb-6 text-center">PIN CODE DETAILS OF {@name}</h1>
      <table class="min-w-full border-collapse border border-gray-300">
        <thead>
          <tr>
            <.t_header name="POST OFFICE" />
            <.t_header name="PINCODE" />
            <.t_header name="STATE" />
            <.t_header name="DISTRICT" />
          </tr>
        </thead>
        <tbody id="post_office1">
          <tr>
            <.t_item name={@post_office.office_name} is_btn={false} />
            <.t_item name={@post_office.pincode} is_btn={false} />
            <.t_item name={@post_office.state_name} is_btn={false} />
            <.t_item name={@post_office.district} is_btn={false} />
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def t_header(assigns) do
    ~H"""
    <th class={["border border-gray-500 bg-gray-300 px-4 py-2 items-center justify-center"]}>
      {@name}
    </th>
    """
  end

  def t_item(assigns) do
    ~H"""
    <th class={["border border-gray-500  px-4 py-2 items-center justify-center"]}>
      <button
        :if={@is_btn}
        class="text-blue-400"
        phx-click={JS.push("district", value: %{district: @name})}
      >
        {@name}
      </button>
      {if !@is_btn, do: @name}
    </th>
    """
  end

  def th_btn(assigns) do
    ~H"""
    <th class={["border border-gray-500  px-4 py-2 items-center justify-center"]}>
      <button class="text-blue-400" phx-click={JS.push(@event, value: @val)}>
        {@name}
      </button>
    </th>
    """
  end

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
