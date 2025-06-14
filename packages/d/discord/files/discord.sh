#!/usr/bin/env sh
# Launches Discord with flags specified in $XDG_CONFIG_HOME/discord-flags.conf

# Make script fail if `cat` fails for some reason
set -e

# Set default value if variable is unset/null
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

# Attempt to read a config file if it exists
if [ -r "${XDG_CONFIG_HOME}/discord-flags.conf" ]; then
  DISCORD_FLAGS="$(cat "$XDG_CONFIG_HOME/discord-flags.conf")"
fi

# Wayland auto-detection. If the session is a wayland session then this will launch as a Wayland window unless the DISCORD_NO_WAYLAND variable is set
if [ -z "${DISCORD_NO_WAYLAND+set}" ]; then
  if [ -z "${ELECTRON_OZONE_PLATFORM_HINT+set}" ]; then
    export ELECTRON_OZONE_PLATFORM_HINT="auto"
  fi
fi

/usr/share/discord/disable-breaking-updates.py
exec /usr/share/discord/Discord $DISCORD_FLAGS "$@"
