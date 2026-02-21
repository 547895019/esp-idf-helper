#!/usr/bin/env bash
set -euo pipefail

# Capture idf.py help text into references/ so it can be searched quickly.
# Uses ESPIDF_ROOT to activate the environment if available.

OUT_REL="references/idf-py-help.txt"

usage() {
  cat <<'EOF'
Usage:
  capture_idf_help.sh [OPTIONS]

Description:
  Capture idf.py --help output to references/idf-py-help.txt for quick reference.
  Uses ESPIDF_ROOT environment variable if set, otherwise uses idf.py from PATH.

Options:
  -h, --help         Show this help message

Environment:
  ESPIDF_ROOT        Path to ESP-IDF installation (optional)

Example:
  bash capture_idf_help.sh
  ESPIDF_ROOT=/path/to/esp-idf bash capture_idf_help.sh
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2;;
  esac
done

ESPIDF_ROOT="${ESPIDF_ROOT:-}"

cd "$(dirname "$0")/.."  # skill root

if [[ -n "${ESPIDF_ROOT:-}" && -f "$ESPIDF_ROOT/export.sh" ]]; then
  bash -lc "set -euo pipefail; source \"$ESPIDF_ROOT/export.sh\" >/dev/null; idf.py --help" > "$OUT_REL"
elif command -v idf.py >/dev/null 2>&1; then
  idf.py --help > "$OUT_REL"
else
  echo "ERROR: idf.py not found. Either activate ESP-IDF in this shell, or set ESPIDF_ROOT to an ESP-IDF checkout (with export.sh)." >&2
  exit 1
fi

echo "Wrote: $(pwd)/$OUT_REL"
