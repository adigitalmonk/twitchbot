# Twitchbot

Super basic Twitchbot WIP.

Run with:

```
> TWITCH_TOKEN=oauth:<your_token> TWITCH_USER=<bot_username> TWITCH_CHANNEL=<channel_to_join> iex -S mix
```

`TWITCH_CHANNEL` is optional, but the other two will cause issues if they are missing.

Once connected, there's currently only one useful function:

```elixir
> Twitchbot.Client.send_text("your message")
```

This will send a raw message of "your message" to the Twitch IRC websocket.

```elixir
> Twitchbot.Client.send_text("JOIN #myfavoritestreamer")
```

# Resources

- https://dev.twitch.tv/docs/irc/guide
- https://hexdocs.pm/websockex/readme.html
