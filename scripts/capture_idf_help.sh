#!/usr/bin/env bash
set -euo pipefail

# Capture idf.py help text into references/ so it can be searched quickly.
# Uses ESPIDF_ROOT to activate the environment if available.

usage() {
  cat <<'EOF'
Usage:
  capture_idf_help.sh [-h|--help]

Description:
  Runs `idf.py --help` and writes the output to references/idf-py-help.txt
  in the repository root, so it can be searched quickly without an active
  ESP-IDF environment.

Environment:
  ESPIDF_ROOT  Path to an ESP-IDF checkout that contains export.sh.
               If set, the script sources export.sh before running idf.py.
               If not set, idf.py must already be on PATH.

Options:
  -h, --help   Show this help message and exit.

Example:
  ESPIDF_ROOT=/opt/esp-idf bash capture_idf_help.sh
EOF
}

for arg in "$@"; do
  case "$arg" in
    -h|--help) usage; exit 0;;
    *) echo "Unknown argument: $arg" >&2; usage; exit 2;;
  esac
done

OUT_REL="references/idf-py-help.txt"

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
