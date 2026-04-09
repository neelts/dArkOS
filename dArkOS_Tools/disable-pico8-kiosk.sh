#!/bin/bash
# Revert the PICO-8 kiosk mode patch applied by enable-pico8-kiosk.sh.
# Restores emulationstation.service from its .bak file.
#
# Usage:
#   sudo bash disable-pico8-kiosk.sh
# Then reboot.

set -e

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo bash $0)"
  exit 1
fi

UNIT_PATHS=(/etc/systemd/system/emulationstation.service /lib/systemd/system/emulationstation.service /usr/lib/systemd/system/emulationstation.service)

RESTORED=0
for candidate in "${UNIT_PATHS[@]}"; do
  if [[ -f "${candidate}.bak" ]]; then
    cp -a "${candidate}.bak" "$candidate"
    echo "Restored $candidate from backup."
    RESTORED=1
  fi
done

if [[ $RESTORED -eq 0 ]]; then
  echo "No .bak file found next to emulationstation.service — nothing to restore."
  echo "If you patched the unit by hand, set ExecStart back to"
  echo "  /usr/bin/emulationstation/emulationstation.sh"
  exit 2
fi

systemctl daemon-reload
echo
echo "Done. Reboot the device to return to EmulationStation."
