defmodule PhoenixYtSeriesWeb.Live.Postcode do
  require Logger
  alias PhoenixYtSeries.Pincodes
  alias PhoenixYtSeries.Pincodes.PincodeIndia
  use PhoenixYtSeriesWeb, :live_view
  import PhoenixYtSeriesWeb.Live.PostComponents

  def mount(_params, _session, socket) do
    if connected?(socket) do
      send(self(), "get_all_states")
    end

    {:ok,
     socket
     |> assign(:page_title, get_page_title(__MODULE__))
     |> assign(uploaded_files: [], show_upload: false, form: to_form(%{}))
     |> assign(
       states: [],
       districts: [],
       offices_dropdown: [],
       post_offices_list: [],
       state: nil,
       district: nil,
       post_office: nil,
       searched: false,
       office_name: nil
     )
     |> stream(:districts_pins, [])
     |> stream(:post_offices_list, [])
     |> stream(:same_pincode_offices, [])
     |> allow_upload(:avatar,
       auto_upload: true,
       accept: ~w(.csv),
       max_entries: 1,
       max_file_size: 35_000_000
     )}
  end

  def handle_event("state", %{"state" => state}, socket) do
    {:ok, %{rows: districts}} = Pincodes.get_statewise(state)

    districts_pins =
      Enum.map(districts, fn d ->
        %{id: Enum.at(d, 0), name: Enum.at(d, 1), pins: Enum.at(d, 2)}
      end)

    districts =
      Enum.map(districts, fn d -> Enum.at(d, 1) end)

    {
      :noreply,
      socket
      |> assign(
        state: state,
        districts: districts,
        district: nil,
        office_name: nil,
        post_office: nil,
        searched: false,
        offices_dropdown: []
      )
      |> stream(:same_pincode_offices, [], reset: true)
      |> stream(:post_offices_list, [], reset: true)
      |> stream(:districts_pins, districts_pins, reset: true)
    }
  end

  def handle_event("district", %{"district" => district}, socket) do
    post_offices = Pincodes.get_district_wise(socket.assigns.state, district)

    offices_dropdown =
      Enum.map(post_offices, fn d -> d.office_name end)

    {:noreply,
     assign(socket,
       offices_dropdown: offices_dropdown,
       post_offices_list: post_offices,
       district: district,
       office_name: nil,
       post_office: nil,
       searched: false
     )
     |> stream(:same_pincode_offices, [], reset: true)
     |> stream(:post_offices_list, post_offices, reset: true)}
  end

  def handle_event("offices_dropdown", %{"post_office" => office_name}, socket) do
    post_offices_list = socket.assigns.post_offices_list
    new_offices = Enum.filter(post_offices_list, fn e -> e.office_name == office_name end)
    office = List.first(new_offices)

    same_pincode_offices =
      Enum.filter(post_offices_list, fn e ->
        e.pincode == office.pincode
      end)

    {
      :noreply,
      assign(socket,
        office_name: office_name,
        post_office: office
      )
      |> stream(:same_pincode_offices, same_pincode_offices, reset: true)
    }
  end

  def handle_event("same_pincode", %{"post_office" => post_office}, socket) do
    office = Ecto.Changeset.cast(%PincodeIndia{}, post_office, PincodeIndia.get_fields()).changes

    {:noreply,
     assign(socket, post_office: office, office_name: office.office_name, searched: false)}
  end

  def handle_event("post_offices", %{"post_office" => post_office}, socket) do
    office = Ecto.Changeset.cast(%PincodeIndia{}, post_office, PincodeIndia.get_fields()).changes
    post_offices_list = socket.assigns.post_offices_list
    new_offices = Enum.filter(post_offices_list, fn e -> e.office_name == office.office_name end)
    office = List.first(new_offices)

    same_pincode_offices =
      Enum.filter(post_offices_list, fn e ->
        e.pincode == office.pincode
      end)

    {:noreply,
     socket
     |> assign(post_office: office, office_name: office.office_name, searched: false)
     |> stream(:same_pincode_offices, same_pincode_offices, reset: true)}
  end

  def handle_event("search", %{"pincode" => pincode}, socket) do
    if Regex.match?(~r/^[0-9]+$/, String.first(pincode)) do
      send(self(), {:pincode, pincode})
    else
      send(self(), {:fetch, pincode})
    end

    {:noreply, socket |> assign(searched: false)}
  end

  def handle_event("uploaded", params, socket) do
    show = if params["show"] == "true", do: false, else: true
    {:noreply, assign(socket, :show_upload, show)}
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
        Pincodes.parse_csv(Path.relative(Path.join(dir, file_name)))
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

  def handle_info({:pincode, pincode}, socket) do
    pincodes_list = Pincodes.get_pincode_wise(pincode)

    case pincodes_list do
      [] ->
        {:noreply, socket}

      list ->
        same_pincode_offices =
          Enum.filter(list, fn e ->
            e.pincode == pincode
          end)

        first_office = List.first(same_pincode_offices)

        {:noreply,
         socket
         |> assign(
           post_office: first_office,
           office_name: first_office.office_name,
           searched: false
         )
         |> stream(:same_pincode_offices, same_pincode_offices, reset: true)}
    end
  end

  def handle_info({:fetch, pincode}, socket) do
    pincodes_list = Pincodes.fetch(pincode)

    case pincodes_list do
      [] ->
        {:noreply, socket}

      list ->
        {:noreply,
         socket
         |> assign(
           office_name: pincode,
           post_offices_list: list,
           post_office: nil,
           district: nil,
           searched: true
         )
         |> stream(:post_offices_list, list, reset: true)}
    end
  end

  def handle_info("get_all_states", socket) do
    states = Pincodes.get_all_states()

    {:noreply, assign(socket, states: states)}
  end

  def handle_info(msg, socket) do
    Logger.warning(msg)
    {:noreply, socket}
  end
end
