# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository manages [ntfy](https://ntfy.sh) server configuration and [launchd](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) service setup for self-hosting on macOS. It is NOT the ntfy source code itself—it only provides configuration, installation scripts, and service management via Makefiles.

## Common Commands

All service management is done via Make targets:

| Command | Purpose |
|---------|---------|
| `make install` | Install config and launchd service (requires `ntfy-server` in PATH) |
| `make start` | Start the server via launchd |
| `make stop` | Stop the server |
| `make restart` | Restart the server |
| `make status` | Show service status and health check |
| `make logs` | Show last 20 lines from stdout/stderr |
| `make logs-follow` | Tail logs continuously |
| `make uninstall` | Remove service (preserves data) |
| `make clean` | Remove all data (destructive) |

## Architecture

### Template-Based Installation

The installation process uses **template substitution** to generate final configuration files:

1. **server.yml** → `~/.config/ntfy/server.yml`
   - `~/Library/Application Support/ntfy` is replaced with the expanded `$(DATA_DIR)` path (Makefile:26)

2. **sh.ntfy.server.plist** → `~/Library/LaunchAgents/sh.ntfy.server.plist`
   - `__NTFY_SERVER_BIN__` → path to `ntfy-server` binary (Makefile:28)
   - `__CONFIG_FILE__` → `~/.config/ntfy/server.yml` (Makefile:29)
   - `__LOG_DIR__` → `~/Library/Logs/ntfy` (Makefile:30)
   - `__DATA_DIR__` → `~/Library/Application Support/ntfy` (Makefile:31)

### Data Layout

All macOS-standard paths are used per [File System Programming Guide](https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html):

- Config: `~/.config/ntfy/`
- Data: `~/Library/Application Support/ntfy/`
- Logs: `~/Library/Logs/ntfy/`
- LaunchAgent: `~/Library/LaunchAgents/sh.ntfy.server.plist`

### Service Management

The launchd service is configured with:
- `RunAtLoad: true` — starts on login
- `KeepAlive: true` — restarts on crash
- Logs split to `ntfy.log` (stdout) and `ntfy.error.log` (stderr)

## Configuration Changes

To modify `server.yml`, edit the template in this repo then:

```bash
make install  # Regenerates ~/.config/ntfy/server.yml
make restart
```

Do NOT edit `~/.config/ntfy/server.yml` directly—it will be overwritten by `make install`.

See [ntfy server configuration docs](https://docs.ntfy.sh/config/) for all available options.

## Building ntfy-server

This repo does NOT build ntfy itself. If you need to build from source, see [macos-dev-setup.md](macos-dev-setup.md), which documents building ntfy with CGO enabled for SQLite support.

Key point from that guide: The standard `make build` in the ntfy source repo targets Linux with cross-compilation. For macOS, use:

```bash
CGO_ENABLED=1 go build -tags "sqlite_omit_load_extension" -o ntfy-server .
```
