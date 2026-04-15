# Copilot Instructions

This repository is **esp-idf-helper** — a collection of shell scripts and reference docs for ESP32/ESP8266 firmware development using Espressif ESP-IDF on Linux/WSL2.

## Project Structure

- `scripts/` — Shell scripts for common ESP-IDF workflows (flash, monitor, menuconfig, usbipd)
- `references/` — Reference docs: `esp-idf-cli.md` and `idf-py-help.txt`
- `SKILL.md` — Main documentation (workflow, command patterns, troubleshooting)

## Conventions

- All scripts are Bash and must be POSIX-compatible where possible
- Scripts accept named arguments (`--project`, `--idf`, `--port`, `--baud`, etc.)
- Target environment: Linux / WSL2 + Windows (usbipd for USB passthrough)
- Serial ports: `/dev/ttyUSB*`, `/dev/ttyACM*`, or WSL-mapped `/dev/ttyS*`
- Default flash baud: 1152000

## Key ESP-IDF Concepts

- `idf.py` is the primary build/flash/monitor tool
- ESP-IDF environment must be sourced via `. $IDF_PATH/export.sh` before use
- `menuconfig` must run in an interactive terminal (never background)
- Flash encryption: use `encrypted-flash` / `encrypted-app-flash` subcommands
- usbipd-win is used to attach USB serial devices to WSL2

## When making changes

- Keep scripts self-contained with clear `--help` output
- Validate required arguments at the top of each script and exit with a clear error message
- Prefer `set -euo pipefail` at the top of scripts
- Update `SKILL.md` if adding new scripts or changing existing behavior
