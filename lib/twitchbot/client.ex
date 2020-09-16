defmodule Twitchbot.Client do
  use GenServer
  import WebSockex, only: [send_frame: 2]

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    IO.puts "Starting TwitchBot"

    {:ok, pid} = Twitchbot.Socket.start_link()

    # move variables to config
    send_text(pid, "PASS " <> System.get_env("TWITCH_TOKEN", ""))
    send_text(pid, "NICK " <> System.get_env("TWITCH_USER", ""))

    join_channel = System.get_env("TWITCH_CHANNEL")
    if join_channel, do: send_text(pid, "JOIN " <> join_channel)

    Process.monitor(pid)
    {:ok, pid}
  end

  def send_text(message) do
    GenServer.cast(__MODULE__, {:send_text, message})
  end

  def handle_cast({:send_text, message}, pid) do
    send_text(pid, message)

    {:noreply, pid}
  end

  def handle_info({:DOWN, _ref, :process, _object, _reason}, state) do
    {:stop, :restart, state}
  end

  defp send_text(pid, message) do
    send_frame(pid, {:text, message})
  end
end
