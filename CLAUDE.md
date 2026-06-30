# CLAUDE.md

> **Keep in sync with AGENTS.md.** Any update to one file must be reflected in the other.

## Project Overview

<!-- TODO: Complete this section with a description of what this workflow does -->

## Tech Stack

- **Platform:** n8n (self-hosted or cloud)
- **Workflow format:** n8n JSON exports (`.json`)
- **Credentials:** Managed via `.env` (never committed)

## AI Tooling

### MCP Server — n8n-mcp

- Installed at `./n8n-mcp/` (gitignored, built locally)
- Project-scoped via `.mcp.json` → `start-mcp.sh` (sources `.env` at runtime)
- Provides 25 tools: node search, template library, live workflow management, validation
- Instance: `https://n8n.digenie.link/`

### Claude Code Skills — n8n-skills

Installed globally at `~/.claude/skills/`. Activate automatically on relevant queries.

| Skill | Purpose |
| --- | --- |
| `n8n-expression-syntax` | Correct `{{}}` patterns, `$json`/`$node` variables |
| `n8n-mcp-tools-expert` | MCP tool selection, nodeType formats, parameter structures |
| `n8n-workflow-patterns` | 5 proven architectural patterns (webhook, API, DB, AI, scheduled) |
| `n8n-validation-expert` | Validation error interpretation and fixing |
| `n8n-node-configuration` | Property dependencies, operation-aware setup |
| `n8n-code-javascript` | JavaScript in Code nodes, `$input`/`$helpers` patterns |
| `n8n-code-python` | Python in Code nodes, standard-library-only limitations |

### MCP Server — openaiDeveloperDocs

Always use the OpenAI developer documentation MCP server if you need to work with the OpenAI API, ChatGPT Apps SDK, Codex, etc. — without me having to explicitly ask.

### Claude Code Skill — openai-docs

Project-scoped at `.claude/skills/openai-docs/SKILL.md`. Activates automatically for OpenAI API, Responses API, Apps SDK, Agents SDK, and model-selection queries; drives the `openaiDeveloperDocs` MCP tools (search/fetch/OpenAPI spec).

## Build, Debug & Optimise

### Running workflows

- Import workflow JSON files into your n8n instance via the UI or the n8n CLI.
- Use the n8n execution log to debug node failures.

### Debugging

- Enable **Save manual executions** in n8n settings to inspect intermediate node outputs.
- Use the **Debug** execution mode where available to step through nodes.

### Optimising

- Prefer batch operations over single-item loops where n8n nodes support them.
- Use **Split in Batches** nodes to avoid memory pressure on large datasets.
- Pin frequently referenced static data using n8n's **Code** node with module caching patterns.

### Deploying Workflow Changes

- After editing a workflow JSON file in `workflows/` and validating it locally (`n8n_validate_workflow` / `validate_workflow`), push the change to the live n8n instance via `n8n_update_full_workflow` (or `n8n_update_partial_workflow`) without waiting to be asked.
- Match the live workflow by name via `n8n_list_workflows` to find its ID.
- Only skip the live push if the user explicitly says to hold off, or if validation surfaces unresolved errors.

## Sync Requirement

When updating this file, also update **AGENTS.md** to keep conventions aligned.
