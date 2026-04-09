#!/bin/bash
# dArkOS PICO-8 kiosk autoboot.
# Reads StartupOnRom from es_settings.cfg:
#   (empty) / none  → skip autoboot, go straight to ES
#   splore          → launch PICO-8 Splore
#   recent          → launch last played cart from activity log, fallback to Splore

sleep 2

MODE=$(grep 'name="StartupOnRom"' /home/ark/.emulationstation/es_settings.cfg 2>/dev/null \
  | grep -oP '(?<=value=").*?(?=")')

case "$MODE" in
  splore)
    /usr/local/bin/pico8.sh float-scaled /roms/pico-8/carts/zzzsplore.p8
    ;;
  recent)
    LAST_GAME=$(tac /opt/pico-8/activity_log.txt 2>/dev/null \
      | grep -m1 "\.p8" \
      | grep -iv "zzzsplore" \
      | grep -oP '(?<= /).*')
    if [[ -n "$LAST_GAME" ]] && [[ -f "/$LAST_GAME" ]]; then
      /usr/local/bin/pico8.sh float-scaled "/$LAST_GAME"
    else
      /usr/local/bin/pico8.sh float-scaled /roms/pico-8/carts/zzzsplore.p8
    fi
    ;;
  *)
    # NONE or unset — skip straight to ES
    ;;
esac

exec /usr/bin/emulationstation/emulationstation.sh
