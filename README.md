# ntfy-config

Configuration and [launchd](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) service setup for self-hosting [ntfy](https://ntfy.sh) on macOS.

## Prerequisites

You need `ntfy-server` built and installed. See [macos-dev-setup.md](macos-dev-setup.md) for building from source, or if you have a pre-built binary, ensure it's in your `PATH`.

```bash
which ntfy-server  # should return a path
```

## Installation

```bash
make install
make start
```

The server will be available at **http://localhost:9876** and will auto-start on login.

## Usage

| Command | Description |
|---------|-------------|
| `make install` | Install config and launchd service |
| `make uninstall` | Remove service (preserves data) |
| `make start` | Start the server |
| `make stop` | Stop the server |
| `make restart` | Restart the server |
| `make status` | Show service status and health |
| `make logs` | Show recent logs |
| `make logs-follow` | Tail logs continuously |
| `make clean` | Remove all data (destructive) |

## Sending notifications

```bash
# Simple message
curl -d "Hello!" http://localhost:9876/my-topic

# With title and priority
curl -H "Title: Alert" -H "Priority: high" -d "Something happened" http://localhost:9876/my-topic
```

See the [ntfy publishing docs](https://docs.ntfy.sh/publish/) for more options.

## File locations

| File | Path |
|------|------|
| Config | `~/.config/ntfy/server.yml` |
| Cache DB | `~/Library/Application Support/ntfy/cache.db` |
| Attachments | `~/Library/Application Support/ntfy/attachments/` |
| Logs | `~/Library/Logs/ntfy/` |
| Launchd plist | `~/Library/LaunchAgents/sh.ntfy.server.plist` |

## Configuration

Edit `server.yml` in this repo, then reinstall:

```bash
make install
make restart
```

See [ntfy server configuration](https://docs.ntfy.sh/config/) for all options.

## iOS/Android push notifications

For mobile push notifications on a self-hosted server, you need to configure [upstream forwarding](https://docs.ntfy.sh/config/#ios-instant-notifications) to ntfy.sh. Add to `server.yml`:

```yaml
upstream-base-url: "https://ntfy.sh"
```

## Links

- [ntfy documentation](https://docs.ntfy.sh/)
- [ntfy GitHub](https://github.com/binwiederhier/ntfy)
- [launchd.plist man page](https://keith.github.io/xcode-man-pages/launchd.plist.5.html)
