# esp-idf-helper

A collection of shell scripts and reference documentation for ESP32/ESP8266 firmware development using [Espressif ESP-IDF](https://github.com/espressif/esp-idf) on Linux / WSL2.

> **GitHub Copilot Skill** — `SKILL.md` registers this repo as a Copilot skill so the AI assistant can guide you through the full ESP-IDF workflow.

---

## 功能概述 / What this repo does

| 功能 | 说明 |
|------|------|
| **一键烧录（带进度）** | `scripts/flash_with_progress.sh` — 实时显示烧录进度，支持自动串口映射重试、二次重试、加密烧录 |
| **串口监视器自动恢复** | `scripts/monitor_auto_attach.sh` — 监视器因串口不可用失败时，自动调用 usbipd 映射并重试 |
| **menuconfig 窗口启动** | `scripts/run_menuconfig.sh` — 在正确的 TTY 终端中运行 `idf.py menuconfig` |
| **USB 串口自动映射** | `scripts/usbipd_attach_serial.sh` — 在 WSL2 中自动识别并挂载 Windows USB 串口设备（via usbipd-win） |
| **IDF 帮助文档缓存** | `scripts/capture_idf_help.sh` — 将当前 ESP-IDF 版本的 `idf.py --help` 输出保存到 `references/` 供快速查阅 |
| **参考文档** | `references/esp-idf-cli.md` — 常用命令速查；`references/idf-py-help.txt` — `idf.py` 帮助全文 |
| **Copilot Skill** | `SKILL.md` — 完整工作流文档，供 GitHub Copilot 自动辅助 ESP-IDF 项目开发 |

---

## Scripts

### `flash_with_progress.sh`
Flash firmware with real-time progress output. Supports all `idf.py` flash modes, automatic usbipd USB re-attachment on serial failure, and configurable retries.

```bash
bash scripts/flash_with_progress.sh \
  --project <PROJECT_DIR> \
  --idf <IDF_DIR> \
  --port <PORT> \
  --mode flash          # flash | app-flash | encrypted-flash | encrypted-app-flash | partition-table-flash | storage-flash
```

### `monitor_auto_attach.sh`
Start `idf.py monitor`. If the serial port can't be opened, automatically runs `usbipd_attach_serial.sh` and retries.

```bash
bash scripts/monitor_auto_attach.sh \
  --project <PROJECT_DIR> \
  --idf <IDF_DIR> \
  --port /dev/ttyACM0 \
  --baud 1152000
```

### `run_menuconfig.sh`
Run `idf.py menuconfig` inside a proper interactive TTY (required — menuconfig is a TUI and cannot run in a non-interactive shell).

```bash
bash scripts/run_menuconfig.sh \
  --project <PROJECT_DIR> \
  --idf <IDF_DIR>
```

### `usbipd_attach_serial.sh`
Auto-select and attach a Windows USB serial device to WSL2 using [usbipd-win](https://github.com/dorssel/usbipd-win). Prefers `Connected` + `Shared` state devices; supports keyword filtering.

```bash
bash scripts/usbipd_attach_serial.sh            # auto-select
bash scripts/usbipd_attach_serial.sh --busid 2-1
bash scripts/usbipd_attach_serial.sh --keyword ESP32
bash scripts/usbipd_attach_serial.sh --dry-run
```

### `capture_idf_help.sh`
Refresh `references/idf-py-help.txt` with the help output for the currently installed ESP-IDF version.

```bash
bash scripts/capture_idf_help.sh
```

---

## Quick Start

```bash
# 1. Source ESP-IDF (once per terminal session)
cd /path/to/esp-idf && . ./export.sh

# 2. Build
cd /path/to/your-project
idf.py set-target esp32s3
idf.py build

# 3. Flash (with progress)
bash /path/to/esp-idf-helper/scripts/flash_with_progress.sh \
  --project . --idf /path/to/esp-idf --port /dev/ttyACM0 --mode flash

# 4. Monitor (with auto USB re-attach)
bash /path/to/esp-idf-helper/scripts/monitor_auto_attach.sh \
  --project . --idf /path/to/esp-idf --port /dev/ttyACM0
```

See [`SKILL.md`](SKILL.md) for the full workflow guide, WSL2 USB setup, troubleshooting decision tree, and flash encryption usage.

---

## Requirements

- Linux or WSL2 (Windows Subsystem for Linux)
- [Espressif ESP-IDF](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/) installed and `export.sh` available
- For USB serial on WSL2: [usbipd-win](https://github.com/dorssel/usbipd-win) installed on Windows (Admin PowerShell: `winget install dorssel.usbipd-win`)
