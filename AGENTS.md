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

## General Standards

- All credentials must use n8n credential objects — never hard-code secrets in workflow JSON.
- Workflows must include a trigger node (Webhook, Schedule, or Manual trigger).
- Each workflow JSON file must be stored in the `workflows/` directory.

## Sync Requirement

When updating this file, also update **CLAUDE.md** to keep conventions aligned.
