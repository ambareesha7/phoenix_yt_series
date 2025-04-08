defmodule PhoenixYtSeriesWeb.Live.Chat do
  require Logger
  use PhoenixYtSeriesWeb, :live_view
  # use PhoenixYtSeriesWeb.Component
  # alias PhoenixYtSeriesWeb.Components.Input
  alias PhoenixYtSeriesWeb.Components.Button

  @topic "counter_updates"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(PhoenixYtSeries.PubSub, @topic)

    {:ok,
     assign(socket,
       page_title: get_page_title(__MODULE__),
       counter: PhoenixYtSeries.Counter.get_value(),
       form: to_form(%{})
     )}
  end

  @impl true
  def handle_info({:new_count, new_count}, socket) do
    {:noreply, assign(socket, counter: new_count)}
  end

  @impl true
  def handle_info({:message, _text}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(any, socket) do
    Logger.info("handle in any")
    Logger.info(any)
    {:noreply, socket}
  end

  @impl true
  def handle_event("increment", _params, socket) do
    PhoenixYtSeries.Counter.increment()
    {:noreply, socket}
  end

  @impl true
  def handle_event("send", %{"text" => text}, socket) do
    Phoenix.PubSub.broadcast(PhoenixYtSeries.PubSub, @topic, {:message, text})
    {:noreply, socket}
  end

  @impl true
  def handle_event(event, params, socket) do
    Logger.info("Event #{event}")
    Logger.info("Params #{inspect(params)}")
    {:noreply, socket}
  end
end
