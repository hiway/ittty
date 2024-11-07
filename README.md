# ittty

Is The Text There Yet?

Monitor a URL, notify when some text appears on the page.

## Install

```bash
curl -s https://raw.githubusercontent.com/hiway/ittty/refs/heads/main/ittty.sh > ~/bin/ittty.sh
chmod +x ~/bin/ittty.sh
```

## Configure

```bash
ittty.sh init
```

ittty.sh uses Telegram to send notifications.

- Chat with @BotFather to create a new bot and get bot-token
- Chat with @getidsbot to get your chat-id

## Usage

Manually check configured URL for presence of text

```bash
ittty.sh check
```

Add a cron job to check the URL every 60 minutes

```bash
crontab -e
```

```console
# Add the following line to the crontab
0 * * * * /home/user/bin/ittty.sh check
```

## Notifications

> Once a notification is sent, the script will stop loading the URL.

Run `ittty.sh reset` to start monitoring the URL again.

## Change Configuration

To change the URL or text to monitor, run `ittty.sh config`.
