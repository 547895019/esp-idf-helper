# esp-idf-helper

A collection of shell scripts and reference documentation for ESP32 / ESP8266 firmware development using [Espressif ESP-IDF](https://github.com/espressif/esp-idf) on Linux / WSL2.

> **中文说明见下方 / Chinese description below.**

---

## What this repository does

`esp-idf-helper` provides a **repeatable, command-line-first workflow** that covers every stage of ESP-IDF firmware development:

| Stage | Tool / Script |
|---|---|
| Configure project | `idf.py menuconfig` via `scripts/run_menuconfig.sh` |
| Build firmware | `idf.py build` |
| Flash to device | `scripts/flash_with_progress.sh` (with real-time progress, auto-retry) |
| Serial monitor | `scripts/monitor_auto_attach.sh` (auto USB attach + retry) |
| USB passthrough (WSL2) | `scripts/usbipd_attach_serial.sh` (auto-selects serial device) |
| Reference lookup | `references/esp-idf-cli.md`, `references/idf-py-help.txt` |

### Scripts

| Script | Purpose |
|---|---|
| `scripts/flash_with_progress.sh` | Flash firmware with real-time `esptool` progress output. Supports plain flash, encrypted flash, app-only flash, partition-table flash, and storage-flash. Automatically retries on serial-port errors after re-attaching the USB device via `usbipd`. |
| `scripts/monitor_auto_attach.sh` | Start `idf.py monitor`. If the serial port cannot be opened, automatically run the usbipd attach script and retry once. |
| `scripts/run_menuconfig.sh` | Launch `idf.py menuconfig` in an interactive terminal (required because menuconfig is a TUI application). |
| `scripts/usbipd_attach_serial.sh` | Auto-detect and attach a USB serial device from Windows to WSL2 using `usbipd-win`. Supports `--keyword`, `--busid`, `--distro`, and `--dry-run` options. |
| `scripts/capture_idf_help.sh` | Refresh `references/idf-py-help.txt` for the locally installed ESP-IDF version. |

### Quick start

```bash
# 1. Source the ESP-IDF environment (once per terminal session)
cd /path/to/esp-idf && . ./export.sh

# 2. Build your project
cd /path/to/your/project
idf.py set-target esp32        # set chip target once
idf.py build                   # compile

# 3. Flash (with progress and auto-retry)
bash /path/to/esp-idf-helper/scripts/flash_with_progress.sh \
  --project /path/to/your/project \
  --idf /path/to/esp-idf \
  --port /dev/ttyACM0 \
  --mode flash

# 4. Monitor serial output
idf.py -p /dev/ttyACM0 monitor
```

---

## 功能说明（中文）

`esp-idf-helper` 是一套用于 **ESP32 / ESP8266 固件开发**的辅助 Shell 脚本与参考文档集合，运行于 Linux / WSL2 环境，覆盖从配置、编译、烧录到串口监控的完整工作流。

### 主要功能

| 阶段 | 工具 / 脚本 |
|---|---|
| 项目配置 | `idf.py menuconfig`，通过 `scripts/run_menuconfig.sh` 在新终端窗口启动 |
| 编译固件 | `idf.py build` |
| 烧录固件 | `scripts/flash_with_progress.sh`（实时进度、自动重试） |
| 串口监控 | `scripts/monitor_auto_attach.sh`（自动 USB 映射 + 重试） |
| USB 串口映射（WSL2） | `scripts/usbipd_attach_serial.sh`（自动选择串口设备） |
| 命令速查 | `references/esp-idf-cli.md`、`references/idf-py-help.txt` |

### 脚本说明

| 脚本 | 用途 |
|---|---|
| `scripts/flash_with_progress.sh` | 实时显示 `esptool` 烧录进度，支持普通烧录、加密烧录、仅烧录 App/分区表/文件系统分区，串口异常时自动重试（支持 `--retries`）。 |
| `scripts/monitor_auto_attach.sh` | 启动 `idf.py monitor`，若串口无法打开则自动调用 usbipd 映射脚本并重试。 |
| `scripts/run_menuconfig.sh` | 在交互终端中启动 `idf.py menuconfig`（TUI 界面，必须在独立窗口运行）。 |
| `scripts/usbipd_attach_serial.sh` | 通过 `usbipd-win` 将 Windows USB 串口自动映射到 WSL2，支持 `--keyword`、`--busid`、`--distro`、`--dry-run` 等参数。 |
| `scripts/capture_idf_help.sh` | 刷新 `references/idf-py-help.txt`，匹配本地已安装的 ESP-IDF 版本。 |

### 快速开始

```bash
# 1. 激活 ESP-IDF 环境（每个终端会话执行一次）
cd /path/to/esp-idf && . ./export.sh

# 2. 编译项目
cd /path/to/your/project
idf.py set-target esp32          # 设置目标芯片（每个项目设置一次）
idf.py build                     # 编译

# 3. 烧录（带进度条，自动重试）
bash /path/to/esp-idf-helper/scripts/flash_with_progress.sh \
  --project /path/to/your/project \
  --idf /path/to/esp-idf \
  --port /dev/ttyACM0 \
  --mode flash

# 4. 串口监控
idf.py -p /dev/ttyACM0 monitor
```

完整工作流、故障排查方法及所有脚本参数，请参阅 [SKILL.md](SKILL.md)。
