# CLAUDE.md

> **Keep in sync with AGENTS.md.** Any update to one file must be reflected in the other.

## Project Overview

<!-- TODO: Complete this section with a description of what this workflow does -->

## Tech Stack

- **Platform:** n8n (self-hosted or cloud)
- **Workflow format:** n8n JSON exports (`.json`)
- **Credentials:** Managed via `.env` (never committed)

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

## Sync Requirement

When updating this file, also update **AGENTS.md** to keep conventions aligned.
