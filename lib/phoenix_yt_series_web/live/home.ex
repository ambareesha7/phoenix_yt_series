defmodule PhoenixYtSeriesWeb.Live.Home do
  require Logger
  use PhoenixYtSeriesWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: get_page_title(__MODULE__))}
  end

  def render(assigns) do
    ~H"""
    <%!-- Home page --%>
    <div>
      <h1 class="text-brand py-4 flex justify-center text-3xl">
        LiveView 1.0
      </h1>
      <div class="flex flex-col justify-center items-center">
        <div class="  text-2xl pb-1 ">
          Build postal pincode search engin in LiveView
        </div>
        <div class="  text-2xl pb-1 font-bold">
          Part-2
        </div>
        <ol class="list-disc text-2xl ">
          <li>Upload CSV file of pincodes</li>
          <li class="text-2xl pb-1 font-bold">Add data from uploaded CSV file to DB</li>
          <li class="text-2xl pb-1 font-bold">Build searchable features</li>
        </ol>
      </div>
    </div>
    """
  end

  def handle_event(_anything, params, socket) do
    {:noreply, socket |> put_flash(:info, "Anything: #{inspect(params)}")}
  end
end
