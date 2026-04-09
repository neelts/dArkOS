#!/bin/bash
# PICO-8 Boot Settings
# Lets the user choose what to launch on boot: Splore or last played ROM.

CONFIG=/roms/pico-8/autoboot_mode
CURRENT=$(cat "$CONFIG" 2>/dev/null || echo "splore")

if [[ "$CURRENT" == "last_played" ]]; then
  CURRENT_LABEL="Last Played ROM"
else
  CURRENT_LABEL="Splore"
fi

sudo chmod 666 /dev/tty1
printf "\033c" > /dev/tty1
sudo setfont /usr/share/consolefonts/Lat7-TerminusBold28x14.psf.gz 2>/dev/null

CHOICE=$(dialog --clear --stdout \
  --title "PICO-8 Boot Settings" \
  --menu "Current: $CURRENT_LABEL\n\nBoot into:" 12 50 2 \
  "splore"      "Splore (cart browser)" \
  "last_played" "Last Played ROM")

if [[ $? -eq 0 ]]; then
  echo "$CHOICE" > "$CONFIG"
  if [[ "$CHOICE" == "last_played" ]]; then
    LABEL="Last Played ROM"
  else
    LABEL="Splore"
  fi
  dialog --clear --stdout --title "PICO-8 Boot Settings" \
    --msgbox "Boot mode set to: $LABEL" 6 40
fi

printf "\033c" > /dev/tty1
