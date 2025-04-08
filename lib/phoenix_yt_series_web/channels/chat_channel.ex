defmodule PhoenixYtSeriesWeb.ChatChannel do
  use PhoenixYtSeriesWeb, :channel
  alias Phoenix.PubSub
  require Logger

  @topic "counter_updates"

  def join("chat:lobby", payload, socket) do
    if authorized?(payload) do
      PubSub.subscribe(PhoenixYtSeries.PubSub, @topic)
      Logger.info("Flutter client connected and subscribed to counter updates")
      Process.send_after(self(), :after_join, 100)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("chat:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  # Handle messages broadcasted by PubSub
  def handle_info({:new_count, count}, socket) do
    Logger.warning("Flutter client receiving an increment event")
    push(socket, "new_count", %{count: count})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    Logger.info("Flutter client joined the channel")
    push(socket, "new_count", %{count: PhoenixYtSeries.Counter.get_value()})
    {:noreply, socket}
  end

  def handle_info({:message, message}, socket) do
    Logger.info("Broadcasting message: #{inspect(message)}")
    push(socket, "broadcast", %{text: message})
    {:noreply, socket}
  end

  # Handle incoming "increment" events from the client
  def handle_in("increment", _payload, socket) do
    Logger.warning("Flutter client sent an increment event")
    # Increment the counter through the GenServer
    PhoenixYtSeries.Counter.increment()
    {:noreply, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chat:lobby).
  def handle_in("shout", payload, socket) do
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(payload) do
    Logger.info("Authorizing user", payload: inspect(payload))
    true
  end
end
