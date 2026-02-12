---
name: esp-idf-helper
description: Help develop, build, flash, and debug ESP32/ESP8266 firmware using Espressif ESP-IDF on Linux/WSL. Use when the user asks about ESP-IDF project setup, configuring targets, menuconfig, building, flashing via esptool/idf.py, serial monitor, partition tables, sdkconfig, troubleshooting build/flash/monitor errors, or automating common idf.py workflows from the command line.
---

# esp-idf-helper

## Goal
Provide a repeatable, command-line-first workflow for ESP-IDF development on Linux/WSL: configure → build → flash → monitor → debug/troubleshoot.

## Quick start (typical loop)

### Method 1: Activate ESP-IDF first (Recommended)
```bash
# 1) Source the ESP-IDF environment (once per terminal session)
cd /path/to/esp-idf
. ./export.sh

# 2) Go to your project and build
cd /path/to/your/project
idf.py set-target <target>    # Set target chip (once per project)
idf.py build                 # Compile
idf.py -p <PORT> -b <BAUD> flash  # Flash to device (optional)
```

### Common commands
- `idf.py set-target <target>` — Set chip target: esp32, esp32s2, esp32s3, esp32c3, esp32p4
- `idf.py menuconfig` — Configure project settings
- `idf.py build` — Build the project
- `idf.py size` — Show firmware size information
- `idf.py -p <PORT> -b <BAUD> flash` — Flash firmware (default baud: 1152000)
- `idf.py -p <PORT> monitor` — Open serial monitor
- `idf.py -p <PORT> -b <BAUD> flash monitor` — Flash then monitor
- `idf.py fullclean` — Clean build directory

## Workflow decision tree
- If the user has **no project yet** → create from example/template; confirm target chip and IDF version.
- If **build fails** → collect the *first* error lines; identify missing deps/toolchain/cmake/python packages; confirm IDF env.
- If **flash fails** → confirm PORT permissions/WSL USB passthrough, baud rate, boot mode, correct chip target.
- If **monitor is gibberish** → wrong baud (monitor uses app baud), wrong serial adapter settings, or wrong console encoding.
- If **boot loop / panic** → request panic backtrace; decode with `addr2line` (or `idf.py monitor` built-in) and check partition/sdkconfig.

## What to ask the user for (minimal)
1) Chip target: e.g. `esp32`, `esp32s2`, `esp32s3`, `esp32c3`, `esp32p4`.
2) ESP-IDF version + how it’s installed/activated (IDF Tools installer vs git clone; `IDF_PATH` / `ESPIDF_ROOT`).
3) Project path + whether it’s an ESP-IDF project (has `CMakeLists.txt`, `main/`, `sdkconfig`).
4) Serial port path: e.g. `/dev/ttyUSB0`, `/dev/ttyACM0`, or WSL mapped (often `/dev/ttyS*`).
5) Exact failing command + the *first* error block in output.

## New Feature: Create ESP-IDF Projects
- **Description**: Create a new ESP-IDF project or create a project from an example in the ESP Component Registry.
- **Usage**:
  ```bash
  idf.py create-project <project_name> <project_path>
  idf.py create-project-from-example <example_name> <project_path>
  ```

## Bundled resources
### references/
- `references/esp-idf-cli.md` — concise command patterns + what to paste back when reporting errors.
- `references/idf-py-help.txt` — captured `idf.py --help` output for quick lookup/search.

To refresh the help text for your installed ESP-IDF version, run:
- `scripts/capture_idf_help.sh`

### assets/
Not used by default.