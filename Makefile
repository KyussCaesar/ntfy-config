# ntfy server installation for macOS
# https://docs.ntfy.sh/

SHELL := /bin/bash

# Paths
NTFY_SERVER_BIN := $(shell which ntfy-server)
CONFIG_DIR := $(HOME)/.config/ntfy
DATA_DIR := $(HOME)/Library/Application Support/ntfy
LOG_DIR := $(HOME)/Library/Logs/ntfy
LAUNCH_AGENTS := $(HOME)/Library/LaunchAgents
PLIST_NAME := sh.ntfy.server.plist

.PHONY: install uninstall start stop restart status logs logs-follow clean

install:
	@if [ -z "$(NTFY_SERVER_BIN)" ]; then \
		echo "Error: ntfy-server not found in PATH"; \
		exit 1; \
	fi
	@echo "Creating directories..."
	@mkdir -p "$(CONFIG_DIR)"
	@mkdir -p "$(DATA_DIR)"
	@mkdir -p "$(LOG_DIR)"
	@echo "Installing config to $(CONFIG_DIR)/server.yml"
	@sed 's|~/Library/Application Support/ntfy|$(DATA_DIR)|g' server.yml > "$(CONFIG_DIR)/server.yml"
	@echo "Installing launchd plist to $(LAUNCH_AGENTS)/$(PLIST_NAME)"
	@sed -e 's|__NTFY_SERVER_BIN__|$(NTFY_SERVER_BIN)|g' \
	     -e 's|__CONFIG_FILE__|$(CONFIG_DIR)/server.yml|g' \
	     -e 's|__LOG_DIR__|$(LOG_DIR)|g' \
	     -e 's|__DATA_DIR__|$(DATA_DIR)|g' \
	     sh.ntfy.server.plist > "$(LAUNCH_AGENTS)/$(PLIST_NAME)"
	@echo ""
	@echo "ntfy server installed successfully"
	@echo ""
	@echo "To start the service:"
	@echo "  make start"
	@echo ""
	@echo "Server will be available at: http://localhost:9876"

uninstall: stop
	@echo "Removing ntfy server installation..."
	@rm -f "$(LAUNCH_AGENTS)/$(PLIST_NAME)"
	@rm -f "$(CONFIG_DIR)/server.yml"
	@echo "Uninstalled. Data in $(DATA_DIR) preserved."

start:
	@launchctl load "$(LAUNCH_AGENTS)/$(PLIST_NAME)"
	@echo "ntfy server started"

stop:
	@-launchctl unload "$(LAUNCH_AGENTS)/$(PLIST_NAME)" 2>/dev/null
	@echo "ntfy server stopped"

restart: stop start

status:
	@launchctl list | grep -E "PID|sh.ntfy" || echo "Service not loaded"
	@echo ""
	@curl -sf http://localhost:9876/v1/health && echo "Server is healthy" || echo "Server not responding"

logs:
	@echo "=== stdout ==="
	@tail -20 "$(LOG_DIR)/ntfy.log" 2>/dev/null || echo "(no logs yet)"
	@echo ""
	@echo "=== stderr ==="
	@tail -20 "$(LOG_DIR)/ntfy.error.log" 2>/dev/null || echo "(no errors)"

logs-follow:
	@tail -f "$(LOG_DIR)/ntfy.log" "$(LOG_DIR)/ntfy.error.log"

clean:
	@echo "This will remove all ntfy data including cached messages."
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ]
	@rm -rf "$(DATA_DIR)"
	@rm -rf "$(LOG_DIR)"
	@rm -rf "$(CONFIG_DIR)"
	@echo "Cleaned"
