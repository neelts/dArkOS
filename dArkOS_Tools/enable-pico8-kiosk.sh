#!/bin/bash
# Enable PICO-8 splore kiosk mode on a running dArkOS device.
#
# Hijacks emulationstation.service so that on boot the device launches
# directly into PICO-8 Splore via pico8.sh's zzzsplore sentinel path.
#
# Idempotent. Backs up the original service unit so disable-pico8-kiosk.sh
# can restore it.
#
# Usage (from the device, as ark):
#   sudo bash enable-pico8-kiosk.sh
# Then reboot.

set -e

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (sudo bash $0)"
  exit 1
fi

AUTOBOOT=/usr/local/bin/pico8-autoboot.sh
UNIT_PATHS=(/etc/systemd/system/emulationstation.service /lib/systemd/system/emulationstation.service /usr/lib/systemd/system/emulationstation.service)

# 1. Install the autoboot wrapper.
cat > "$AUTOBOOT" <<'EOF'
#!/bin/bash
# dArkOS PICO-8 kiosk autoboot. Launches PICO-8 in -splore mode via
# pico8.sh's zzzsplore filename sentinel. The path need not exist.
sleep 2
exec /usr/local/bin/pico8.sh float-scaled /roms/pico-8/carts/zzzsplore.p8
EOF
chmod 755 "$AUTOBOOT"
echo "Installed $AUTOBOOT"

# 2. Locate the installed emulationstation.service unit and patch ExecStart.
UNIT=""
for candidate in "${UNIT_PATHS[@]}"; do
  if [[ -f "$candidate" ]]; then
    UNIT="$candidate"
    break
  fi
done
if [[ -z "$UNIT" ]]; then
  echo "ERROR: could not find emulationstation.service in any of:"
  printf '  %s\n' "${UNIT_PATHS[@]}"
  exit 2
fi
echo "Found service unit: $UNIT"

if [[ ! -f "${UNIT}.bak" ]]; then
  cp -a "$UNIT" "${UNIT}.bak"
  echo "Backed up original to ${UNIT}.bak"
else
  echo "Backup ${UNIT}.bak already exists — leaving as-is."
fi

# Replace the ExecStart line. Use a fixed pattern so re-runs stay idempotent.
if grep -q "^ExecStart=${AUTOBOOT}$" "$UNIT"; then
  echo "ExecStart already pointed at $AUTOBOOT — nothing to do."
else
  sed -i "s|^ExecStart=.*|ExecStart=${AUTOBOOT}|" "$UNIT"
  echo "Patched ExecStart -> $AUTOBOOT"
fi

# 3. Reload systemd so it picks up the change on next boot.
systemctl daemon-reload
echo
echo "Done. Reboot the device to enter PICO-8 kiosk mode."
echo "If splore fails to launch (e.g. pico8_64 binary missing), run"
echo "disable-pico8-kiosk.sh to restore EmulationStation."
