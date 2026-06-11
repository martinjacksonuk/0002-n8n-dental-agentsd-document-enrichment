#!/bin/bash
# Loads credentials from .env at runtime so nothing sensitive is stored in .mcp.json.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -a
# shellcheck disable=SC1091
source "$SCRIPT_DIR/.env"
set +a

exec npx @digitalocean/mcp --services apps,databases,droplets
