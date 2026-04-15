#!/usr/bin/env bash
set -euo pipefail

# Auto map a USB serial device from Windows to WSL2 via usbipd
# Usage:
#   usbipd_attach_serial.sh [--busid <BUSID>] [--distro <DISTRO>] [--keyword <TEXT>] [--dry-run]

BUSID=""
DISTRO=""
KEYWORD=""
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage:
  usbipd_attach_serial.sh [--busid <BUSID>] [--distro <DISTRO>] [--keyword <TEXT>] [--dry-run]

Options:
  --busid <BUSID>    Specify bus id directly, e.g. 2-1
  --distro <DISTRO>  WSL distro name for attach command (optional)
  --keyword <TEXT>   Filter device line by keyword (e.g. ESP32, COM37, CP210x)
  --dry-run          Print command only, do not execute
  --bind             Only bind the device (skip attach), useful for first-time setup
  -h, --help         Show help

Behavior:
  1) Reads `usbipd list` from Windows PowerShell
  2) Auto-selects first "Connected" serial-like device (prefer STATE=Shared)
  3) Executes: usbipd bind --busid=<BUSID> (admin required, makes device shareable)
  4) Executes: usbipd attach --wsl --busid=<BUSID> [--distribution <DISTRO>]
  5) Prints detected /dev/ttyACM* and /dev/ttyUSB* in WSL
  (Use --bind to only perform bind, skip attach)
EOF
}

BIND_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --busid) BUSID="${2:-}"; shift 2;;
    --distro) DISTRO="${2:-}"; shift 2;;
    --keyword) KEYWORD="${2:-}"; shift 2;;
    --dry-run) DRY_RUN=1; shift;;
    --bind) BIND_ONLY=1; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

PS_LIST=$(powershell.exe -NoProfile -Command "usbipd list" | tr -d '\r')

echo "=== usbipd list ==="
echo "$PS_LIST"

auto_pick_busid() {
  local lines
  lines=$(echo "$PS_LIST" | awk '
    BEGIN{inConnected=0}
    /^Connected:/ {inConnected=1; next}
    /^Persisted:/ {inConnected=0}
    { if (inConnected) print }
  ')

  # Keep likely serial rows only
  local serial_rows
  serial_rows=$(echo "$lines" | grep -E "USB 串行设备|USB JTAG/serial debug unit|USB-Enhanced-SERIAL|CP210|CH34|FTDI|Serial|UART|ESP32" || true)

  if [[ -n "$KEYWORD" ]]; then
    serial_rows=$(echo "$serial_rows" | grep -i -- "$KEYWORD" || true)
  fi

  # Prefer Shared first
  local preferred
  preferred=$(echo "$serial_rows" | grep -E "Shared\s*$" | head -n1 || true)
  if [[ -z "$preferred" ]]; then
    preferred=$(echo "$serial_rows" | head -n1 || true)
  fi

  if [[ -n "$preferred" ]]; then
    echo "$preferred" | awk '{print $1}'
  fi
}

if [[ -z "$BUSID" ]]; then
  BUSID=$(auto_pick_busid || true)
fi

if [[ -z "$BUSID" ]]; then
  echo "ERROR: No candidate BUSID found. Please specify --busid <BUSID>." >&2
  exit 1
fi

CMD="usbipd attach --wsl --busid=$BUSID"
if [[ -n "$DISTRO" ]]; then
  CMD+=" --distribution $DISTRO"
fi

echo "Selected BUSID: $BUSID"
echo "Attach command: $CMD"

# Bind the device first (admin may be required for first-time bind)
BIND_CMD="usbipd bind --busid=$BUSID"
echo "Bind command: $BIND_CMD"

if [[ "$DRY_RUN" == "1" ]]; then
  echo "[dry-run] not executing bind/attach"
  exit 0
fi

# Execute bind (may fail if already bound, that's ok)
set +e
BIND_OUT=$(powershell.exe -NoProfile -Command "$BIND_CMD" 2>&1)
BIND_RC=$?
set -e
if [[ $BIND_RC -ne 0 ]]; then
  if echo "$BIND_OUT" | grep -qi "already bound\|already shared"; then
    echo "[info] device already bound/shared, continue."
  else
    echo "[warn] bind failed (may require admin): $BIND_OUT"
  fi
else
  echo "$BIND_OUT"
fi

if [[ "$BIND_ONLY" == "1" ]]; then
  echo "[info] bind-only mode, skipping attach."
  exit 0
fi

set +e
ATTACH_OUT=$(powershell.exe -NoProfile -Command "$CMD" 2>&1)
ATTACH_RC=$?
set -e
echo "$ATTACH_OUT"
if [[ $ATTACH_RC -ne 0 ]]; then
  if echo "$ATTACH_OUT" | grep -qi "already attached"; then
    echo "[info] device already attached, continue."
  else
    echo "[error] attach failed" >&2
    exit "$ATTACH_RC"
  fi
fi

echo "\n=== WSL serial nodes ==="
found=0
for pat in /dev/ttyACM* /dev/ttyUSB*; do
  for dev in $pat; do
    if [[ -e "$dev" ]]; then
      echo "$dev"
      found=1
    fi
  done
done
if [[ "$found" -eq 0 ]]; then
  echo "No /dev/ttyACM* or /dev/ttyUSB* yet."
fi

echo "Done."
