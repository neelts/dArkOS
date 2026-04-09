#!/bin/bash
# Launcher wrapper for the PICO-8 ES system.
# Routes .sh files (settings/tools) to bash, everything else to pico8.sh.

ROM="$2"
ext="${ROM##*.}"

if [[ "${ext,,}" == "sh" ]]; then
  bash "$ROM"
else
  sudo systemctl start pico8hotkey
  /usr/local/bin/pico8.sh "$1" "$ROM"
  sudo systemctl stop pico8hotkey
fi
