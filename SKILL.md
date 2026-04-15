---
name: esp-idf-helper
description: Help develop, build, flash, and debug ESP32/ESP8266 firmware using Espressif ESP-IDF on Linux/WSL. Use when the user asks about ESP-IDF project setup, configuring targets, menuconfig, building, flashing via esptool/idf.py, serial monitor, partition tables, sdkconfig, troubleshooting build/flash/monitor errors, or automating common idf.py workflows from the command line.
homepage: https://github.com/espressif/esp-idf
metadata:
  {
    "esp-idf-helper":
      {
        "emoji": "🤖",
        "requires": { "bins": ["idf.py"], "env": ["IDF_PATH"] },
        "primaryEnv": "IDF_PATH",
      },
  }
---

# esp-idf-helper Skill

Provide a repeatable, command-line-first workflow for ESP-IDF development on Linux/WSL: configure → build → flash → monitor → debug/troubleshoot.

## Quick Reference

```bash
# 1) Source the ESP-IDF environment (once per terminal session)
. $IDF_PATH/export.sh

# 1.1) Enable ccache to speed up compilation (recommended)
export IDF_CCACHE_ENABLE=1

# 2) Go to your project and build
cd /path/to/your/project
idf.py set-target <target>    # Set target chip (once per project)
idf.py build                 # Compile

# 3) flash
idf.py -p <PORT> -b <BAUD> flash  # Flash to device (optional)
```

### Common commands
- `idf.py --help` — Help
- `idf.py set-target <target>` — Set chip target: esp32, esp32s2, esp32s3, esp32c3, esp32p4
- `idf.py menuconfig` — Configure project settings (**must run in a new terminal window**)
- `idf.py build` — Build the project
- `idf.py update-dependencies` — Update project component dependencies
- `idf.py partition-table` — Build partition table and print partition entries
- `idf.py partition-table-flash` — Flash partition table to device
- `idf.py storage-flash` — Flash storage filesystem partition
- `idf.py size` — Show firmware size information
- `idf.py -p <PORT> -b <BAUD> flash` — Flash firmware (default baud: 1152000)
- `idf.py -p <PORT> monitor` — Open serial monitor
- `idf.py -p <PORT> -b <BAUD> monitor` — Open serial monitor with specific baud (e.g. 1152000)
- `idf.py -p <PORT> -b <BAUD> flash monitor` — Flash then monitor

## Component Management

ESP-IDF projects can include external components from the **ESP Component Registry**.

- **Registry Website:** https://components.espressif.com/components
- **Search components:** Browse or search for components on the registry website

### Component Commands
- `idf.py add-dependency "<component>"` — Add a component dependency to `idf_component.yml`
- `idf.py update-dependencies` — Download and update all project dependencies

### Component Management Workflow
```bash
# 1) Add a dependency to your project
idf.py add-dependency "<component>"

# 2) Update dependencies (downloads components to managed_components/)
idf.py update-dependencies

```

**Note:** Dependencies are recorded in `idf_component.yml` in your project's main component directory (`main/`).

## Bundled resources
### references/
- `references/esp-idf-cli.md` — concise command patterns + what to paste back when reporting errors.
- `references/idf-py-help.txt` — captured `idf.py --help` output for quick lookup/search.

To refresh the help text for your installed ESP-IDF version, run:
- `scripts/capture_idf_help.sh`

### assets/
Not used by default.

## Serial Port Management (WSL2)

For WSL2 users, USB serial devices need to be attached via **usbipd** to be accessible in WSL.

### List Available Serial Devices
```bash
scripts/usbipd_attach_serial.sh --list
```
Shows all connected USB serial devices (CH340, CH343, CP210, FTDI, etc.).

**Note:** This script runs in WSL2 and uses `powershell.exe` to communicate with Windows usbipd.

### Bind/Attach All Serial Devices
```bash
# Bind and attach all COM port devices
scripts/usbipd_attach_serial.sh --keyword "COM"

# Or attach specific device by busid
scripts/usbipd_attach_serial.sh --busid 3-2

# Or filter by device type
scripts/usbipd_attach_serial.sh --keyword "CH343"
scripts/usbipd_attach_serial.sh --keyword "ESP32"
```

### Serial Port Script Options
- `--list` — List all matching serial devices and exit
- `--busid <BUSID>` — Specify device bus ID (e.g., `3-2`)
- `--keyword <TEXT>` — Filter devices by keyword (e.g., `COM`, `CH343`, `ESP32`)
- `--bind` — Bind only (skip attach), useful for first-time setup with admin privileges
- `--distro <DISTRO>` — Specify WSL distribution name
- `--dry-run` — Print commands without executing

### Typical Workflow
```bash
# 1. Check available devices
scripts/usbipd_attach_serial.sh --list

# 2. Attach all serial devices
scripts/usbipd_attach_serial.sh --keyword "COM"

# 3. Verify devices in WSL
ls -la /dev/ttyACM* /dev/ttyUSB*

# 4. Use with idf.py
idf.py -p /dev/ttyACM0 flash monitor
```

**Note:** This script runs in WSL2 and internally uses `powershell.exe` to communicate with Windows usbipd service.