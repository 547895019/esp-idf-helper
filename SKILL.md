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

# 2) Enable ccache to speed up compilation (recommended)
#    Compilation with ccache: ~3-10x faster for incremental builds
if [ "$IDF_CCACHE_ENABLE" != "1" ]; then
    echo "⚠️  ccache is disabled. Enable for faster builds:"
    echo "    export IDF_CCACHE_ENABLE=1"
    echo ""
fi

# 3) Go to your project and build
cd /path/to/your/project
idf.py set-target <target>    # Set target chip (once per project)
idf.py build                 # Compile

# 4) flash
idf.py -p <PORT> -b <BAUD> flash  # Flash to device (optional)
```

### Common commands
- `idf.py --help` — Help
- `idf.py set-target <target>` — Set chip target: esp32, esp32s2, esp32s3, esp32c3, esp32p4
- `idf.py menuconfig` — Configure project settings via ncurses UI

### Running menuconfig in a Detachable Terminal (tmux)

`idf.py menuconfig` uses ncurses and cannot be directly attached from another terminal session. Use **tmux** to run it in a background session that can be shared:

```bash
# Kill any existing session first
tmux kill-session -t menuconfig_esp 2>/dev/null

# Start menuconfig in a named tmux session
tmux new-session -d -s menuconfig_esp -x 140 -y 45 \
  "cd /path/to/project && . \$IDF_PATH/export.sh > /dev/null 2>&1 && idf.py menuconfig; echo 'Exited'; read -p 'Press Enter'"

# Attach from any terminal to interact
tmux attach -t menuconfig_esp

# When done: press Q to save and exit, or Ctrl+B then D to detach
```

**Alternative — open a new terminal manually:**
```bash
# Just open a new terminal window and run:
cd ~/esp-projects/<project> && . $IDF_PATH/export.sh && idf.py menuconfig
```
- `idf.py build` — Build the project
- `idf.py update-dependencies` — Update project component dependencies
- `idf.py partition-table` — Build partition table and print partition entries
- `idf.py partition-table-flash` — Flash partition table to device
- `idf.py storage-flash` — Flash storage filesystem partition
- `idf.py size` — Show firmware size information
- `idf.py -p <PORT> -b <BAUD> flash` — Flash firmware (default baud: 460800)
- `idf.py -p <PORT> monitor` — Open serial monitor
- `idf.py -p <PORT> -b <BAUD> monitor` — Open serial monitor with specific baud (e.g. 460800)
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

## ESP Board Manager

**ESP Board Manager** 是 Espressif 提供的板级管理工具，用于管理自定义板级配置、自动生成板级代码和 Kconfig 配置。

### Installation

```bash
# 确保 ESP-IDF 环境已加载
. $IDF_PATH/export.sh

# 安装 ESP Board Manager
pip install esp-bmgr-assist
```

### Basic Commands

#### 列出可用板子
```bash
idf.py bmgr -l
# 或
idf.py bmgr --list-boards
```

#### 指定板子（名称或索引）
```bash
# 使用板子名称
idf.py bmgr -b esp_vocat_board_v1_0

# 使用板子索引
idf.py bmgr -b 1
```

#### 使用自定义板子
```bash
idf.py bmgr -b my_board -c /path/to/custom/boards
```

#### 创建新板子
```bash
# 在默认 components 目录创建
idf.py bmgr -n my_new_board

# 在指定路径创建
idf.py bmgr -n path/to/boards/my_new_board
```

#### 仅生成 Kconfig 文件
```bash
idf.py bmgr -b esp_vocat_board_v1_0 --kconfig-only
```

#### 清理生成的文件
```bash
idf.py bmgr -x
# 或
idf.py bmgr --clean
```

### Command Reference

| 选项 | 说明 |
|------|------|
| `-b, --board BOARD` | 板子名称或索引 |
| `-c, --customer-path PATH` | 自定义板子目录（单个或多个） |
| `-l, --list-boards` | 列出所有可用板子并退出 |
| `-n, --new-board ARG` | 创建新板子 |
| `--peripherals-only` | 仅生成外设相关输出；跳过设备生成 |
| `--devices-only` | 仅生成设备相关输出；仍会加载外设配置作为设备引用 |
| `--kconfig-only` | 仅生成 Kconfig 文件；跳过板级代码生成和 sdkconfig 清理 |
| `--skip-sdkconfig-check` | 跳过 sdkconfig 符号一致性检查 |
| `-x, --clean` | 删除生成的 .c/.h 文件，重置生成的 CMakeLists.txt / idf_component.yml，并移除 board_manager.defaults |
| `--log-level LEVEL` | 日志级别：DEBUG, INFO, WARNING, ERROR（默认: INFO） |

### Documentation

- **中文文档:** https://github.com/espressif/esp-gmf/blob/main/packages/esp_board_manager/README_CN.md
- **GitHub:** https://github.com/espressif/esp-gmf/tree/main/packages/esp_board_manager

## Bundled resources
### references/
- `references/idf-py-help.txt` — captured `idf.py --help` output for quick lookup/search.

To refresh the help text for your installed ESP-IDF version, run:
- `scripts/capture_idf_help.sh`

### references/
- `references/idf-py-help.txt` — captured `idf.py --help` output for quick lookup/search.
- `references/header-audit-checklist.md` — checklist and known-unguarded files for esp_oneos component header audit (C++ compatibility).
- `references/extern-c-guard-patch-incident.md` — post-incident analysis: why batch patch corrupted ~50 headers, correct template, verification commands. **Read this before attempting any header guard work on this codebase.**

To refresh the help text for your installed ESP-IDF version, run:

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

### Troubleshooting: powershell.exe not found

If you encounter `powershell.exe: command not found`, the Windows paths are not in your PATH environment variable.

**Quick Fix (current session only):**
```bash
export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"
~/skills/esp-idf-helper/scripts/usbipd_attach_serial.sh --list
```

**Permanent Fix (add to ~/.bashrc):**
```bash
echo 'export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0:/mnt/c/Windows/SysWOW64"' >> ~/.bashrc
source ~/.bashrc
```

## Firmware Packaging

Pack ESP-IDF build output into a distributable firmware package with cross-platform flash scripts.

### Usage
```bash
scripts/pack_firmware.sh <build_directory>
```

### Example
```bash
# After building your project
idf.py build

# Create firmware package
scripts/pack_firmware.sh ./build

# Output: build/firmware_package/ and build/esp_firmware_YYYYMMDD_HHMMSS.zip
```

### Generated Package Contents
| File | Description |
|------|-------------|
| `flash.sh` | Linux/Mac flash script with retry and parallel support |
| `flash.bat` | Windows multi-port flash launcher |
| `flash_one.bat` | Windows single-port flash with retry |
| `mac_addresses.txt` | Recorded MAC addresses (deduplicated) |
| `*.bin` | Firmware binary files |
| `tools/esptool/esptool.exe` | Windows esptool executable |
| `README.txt` | Usage instructions |

### Flash Script Features
- **Auto-retry**: 3 attempts on failure
- **Parallel flashing**: Multiple devices simultaneously
- **MAC recording**: Automatic MAC address extraction and deduplication
- **Cross-platform**: Linux/Mac/Windows support

### Production Workflow
```bash
# 1. Build the project
idf.py build

# 2. Package firmware
scripts/pack_firmware.sh ./build

# 3. Distribute the ZIP to production line
# Production team runs: flash.bat all  (Windows) or ./flash.sh /dev/ttyUSB*  (Linux)
```