# macOS Development Setup

Quick setup guide for building ntfy on macOS with [asdf](https://asdf-vm.com/).

## Prerequisites

Install asdf and add the required plugins:

```bash
# If not already installed
brew install asdf

# Add plugins
asdf plugin add python
asdf plugin add golang
asdf plugin add nodejs
```

## Configure Tool Versions

Create or update `.tool-versions` in the project root:

```bash
asdf install
```

Or install versions manually:

```bash
asdf install python 3.14.2
asdf install golang 1.25.5
asdf install nodejs latest
```

## Build the Web App

```bash
make web-deps  # npm install
make web       # builds to server/site/
```

## Build the Server (with CGO)

The standard `make build` targets Linux with cross-compilation. On macOS, build directly with Go:

```bash
# Create stub files for go:embed (required)
make cli-deps-static-sites

# Build with server support (requires CGO for SQLite)
CGO_ENABLED=1 go build -tags "sqlite_omit_load_extension" -o ntfy-server .
```

## Build Client Only (no server)

If you only need the client (publish/subscribe commands), you can use goreleaser:

```bash
make cli-deps-static-sites cli-deps-all
$(go env GOBIN)/goreleaser build --snapshot --clean --single-target
```

Output: `dist/ntfy_darwin_all_darwin_all/ntfy`

## Install

Copy the binary to a location in your PATH:

```bash
cp ntfy-server ~/.local/bin/
# or
sudo cp ntfy-server /usr/local/bin/
```

## Run the Server

```bash
ntfy-server serve
```

See `ntfy-server serve --help` for configuration options, or refer to the [official docs](https://docs.ntfy.sh/config/).

## Build the Docs (optional)

Requires Python with mkdocs:

```bash
pip install mkdocs mkdocs-material
make docs
```

Or for live preview:

```bash
mkdocs serve
```
