#!/bin/bash
# Loads credentials from .env at runtime so nothing sensitive is stored in .mcp.json.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -a
# shellcheck disable=SC1091
source "$SCRIPT_DIR/.env"
set +a

# n8n-mcp expects N8N_API_URL; our .env uses N8N_BASE_URL
export N8N_API_URL="${N8N_BASE_URL}"
export MCP_MODE=stdio
export LOG_LEVEL=error
export DISABLE_CONSOLE_OUTPUT=true

exec node "$SCRIPT_DIR/n8n-mcp/dist/mcp/stdio-wrapper.js"
