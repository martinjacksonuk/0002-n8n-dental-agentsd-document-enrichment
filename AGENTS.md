# AGENTS.md

> **Keep in sync with CLAUDE.md.** Any update to one file must be reflected in the other.

## Project Conventions & Standards

<!-- TODO: Complete this section with project-specific conventions -->

## Workflow Naming Conventions

<!-- TODO: Define naming convention, e.g. "<ID>_<domain>_<action>.json" -->
<!-- Example: 0002_dental_document_enrichment.json -->

## Node Naming Conventions

<!-- TODO: Define node naming convention -->
<!-- Example: Use sentence-case descriptive labels, e.g. "Fetch patient record", "Enrich with AI" -->

## AI Tooling

### MCP Server — n8n-mcp

- Project-scoped; configured via `.mcp.json` → `start-mcp.sh`
- Credentials sourced from `.env` at runtime — never stored in `.mcp.json`
- Consult the `n8n-mcp-tools-expert` skill before calling any MCP tool

### Claude Code Skills — n8n-skills

Seven skills installed at `~/.claude/skills/` (activate automatically):

- `n8n-expression-syntax`, `n8n-mcp-tools-expert`, `n8n-workflow-patterns`
- `n8n-validation-expert`, `n8n-node-configuration`
- `n8n-code-javascript`, `n8n-code-python`

### MCP Server — openaiDeveloperDocs

Always use the OpenAI developer documentation MCP server if you need to work with the OpenAI API, ChatGPT Apps SDK, Codex, etc. — without me having to explicitly ask.

### Claude Code Skill — openai-docs

Project-scoped at `.claude/skills/openai-docs/SKILL.md`. Activates automatically for OpenAI API, Responses API, Apps SDK, Agents SDK, and model-selection queries; drives the `openaiDeveloperDocs` MCP tools (search/fetch/OpenAPI spec).

## General Standards

- All credentials must use n8n credential objects — never hard-code secrets in workflow JSON.
- Workflows must include a trigger node (Webhook, Schedule, or Manual trigger).
- Each workflow JSON file must be stored in the `workflows/` directory.

## Sync Requirement

When updating this file, also update **CLAUDE.md** to keep conventions aligned.
