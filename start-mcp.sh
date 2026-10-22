#!/usr/bin/env bash
# Compatibility shim (2026-10-22). The real launcher is shared by every project:
#   00_agent_toolkit/mcp/launchers/start-n8n-mcp.sh
# It reads the needed variables from this project's .env by name and never prints
# values. Same interface as before: no args = start (stdio); --check = report
# (exit 0 live, 3 documentation-only, 1 cannot start). Client configs call the
# shared launcher directly; this shim keeps older docs and tools working.
set -euo pipefail
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_DIR="$(cd "$PROJECT_DIR/../00_agent_toolkit" && pwd)"
exec "$TOOLKIT_DIR/mcp/launchers/start-n8n-mcp.sh" "$PROJECT_DIR" "$@"
