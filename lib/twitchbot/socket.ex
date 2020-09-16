defmodule Twitchbot.Socket do
  use WebSockex
  alias Twitchbot.Client
  @twitch_wss "wss://irc-ws.chat.twitch.tv:443"

  def start_link(opts \\ []) do
    WebSockex.start_link(@twitch_wss, __MODULE__, :state, [ {:name, __MODULE__} | opts ])
  end

  def handle_connect(_conn, state) do
    IO.puts "Connected!"
    {:ok, state}
  end

  def handle_disconnect(_reason, state) do
    IO.puts "Disconnected!"
    {:ok, state} # :reconnect ?
  end

  def handle_frame({:text, <<"PING :tmi.twitch.tv"::binary, _::binary>>}, state) do
    IO.puts "Ping? Pong!"
    Client.send_text("PONG :tmi.twitch.tv")

    {:ok, state}
  end

  def handle_frame({:text, message}, state) do
    message
    |> String.split("\r\n", trim: true)
    |> Enum.each(fn line ->
      String.split(line, " ", trim: true, parts: 3)
      |> handle_line()
    end)

    {:ok, state}
  end

  def handle_frame(frame, state) do
    IO.inspect [frame, state], label: "Frame Received"
    {:ok, state}
  end

  def handle_line([source, "JOIN", channel]) do
    IO.puts "#{parse_source(source)} joined #{channel}"
  end

  def handle_line([source, "PRIVMSG", message]) do
    [channel, content] = String.split(message, " ", parts: 2, trim: true)
    IO.puts "[#{channel}] <#{parse_source(source)}> #{content}"
  end

  # Noisy message codes
  def handle_line([_, event_code, _])
    when event_code in ["003", "004", "375", "376", "366"],
    do: :ok

  def handle_line(event_data) do
    IO.inspect event_data, label: "Event"
  end

  def terminate(reason, state) do
    IO.inspect [reason, state], label: "Terminated"
    exit(:normal)
  end

  defp parse_source(source) do
    source
    |> String.split("!", trim: true)
    |> hd()
  end

end
