#!/usr/bin/env bash
#
# ittty: Is The Text There Yet?
#
# Utility to periodically check a URL and notify using Telegram Bot API
# when a configured string is seen on the web page.
#
# Usage:
#
#    ittty.sh init - Configure Telegram Bot API credentials, URL and text to check
#    ittty.sh config - Reconfigure URL and text to check
#    ittty.sh check - Check the URL and notify if the text is found
#    ittty.sh reset - Reset the notification to send again
#
# Add to crontab to run every hour:
#
#    0 * * * * /path/to/ittty.sh check
#
# Dependencies:
#
#    curl
#

# Configuration
CONFIG_FILE="$HOME/.local/share/ittty/config"
CREDENTIALS_FILE="$HOME/.local/share/ittty/credentials"

function init() {
    if [ -f "$CREDENTIALS_FILE" ]; then
        echo "Loading credentials from $CREDENTIALS_FILE"
        source "$CREDENTIALS_FILE"
    else
        # Ensure directory exists
        mkdir -p "$(dirname "$CREDENTIALS_FILE")"

        echo "Chat with @BotFather to create a new bot and get bot-token"
        echo "Chat with @getidsbot to get your chat-id"
        echo ""
        echo "Enter bot-token:"
        read -r BOT_TOKEN
        echo "Enter chat-id:"
        read -r CHAT_ID

        echo "BOT_TOKEN=$BOT_TOKEN" >"$CREDENTIALS_FILE"
        echo "CHAT_ID=$CHAT_ID" >>"$CREDENTIALS_FILE"
        echo ""
        echo "Credentials saved to $CREDENTIALS_FILE"
    fi

    if [ -f "$CONFIG_FILE" ]; then
        echo "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        echo "Enter URL:"
        read -r URL
        echo "Enter text:"
        read -r TEXT

        echo "URL=\"$URL\"" >"$CONFIG_FILE"
        echo "TEXT=\"$TEXT\"" >>"$CONFIG_FILE"
        echo ""
        echo "Configuration saved to $CONFIG_FILE"
    fi
}

function load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        echo "Configuration file not found: $CONFIG_FILE"
        echo "Please run 'ittty.sh init' to create the configuration"
        exit 1
    fi
}

function load_credentials() {
    if [ -f "$CREDENTIALS_FILE" ]; then
        source "$CREDENTIALS_FILE"
    else
        echo "Credentials file not found: $CREDENTIALS_FILE"
        echo "Please run 'ittty.sh init' to create the credentials"
        exit 1
    fi
}

function notification_sent_file() {
    echo "$HOME/.local/share/ittty/$(echo -n "$TEXT" | sha256sum | cut -d' ' -f1).sent"
}

function telegram_api_url() {
    echo "https://api.telegram.org/bot$BOT_TOKEN/sendMessage"
}

function message() {
    echo "$TEXT appeared at $URL"
}

function notify() {
    echo "$TEXT" >"$(notification_sent_file)"
    curl -s -X POST "$(telegram_api_url)" \
        -d "chat_id=$CHAT_ID" \
        -d "text='$(message)'"
    echo ""
    echo "Notification sent"
}

function check_url_and_notify() {
    if curl -s "$URL" | grep -q "$TEXT"; then
        notify
    else
        echo "\"$TEXT\" not found at $URL"
    fi
}

function check() {
    load_config
    load_credentials

    mkdir -p "$HOME/.local/share/ittty"

    sent_file="$(notification_sent_file)"
    if [ -f "$sent_file" ]; then
        echo "Notification already sent, run ittty.sh reset to send again"
    else
        check_url_and_notify
    fi
}

function reset() {
    load_config
    load_credentials

    sent_file="$(notification_sent_file)"
    if [ -f "$sent_file" ]; then
        rm "$sent_file"
        echo "Notification reset, run ittty.sh check to send again"
    else
        echo "Notification not sent yet"
    fi
}

function config() {
    # Remove configuration
    rm -f "$CONFIG_FILE"
    init
}

case "$1" in
init)
    init
    ;;
config)
    config
    ;;
check)
    check
    ;;
reset)
    reset
    ;;
*)
    echo "Usage: $0 {init|config|check|reset}"
    exit 1
    ;;
esac
