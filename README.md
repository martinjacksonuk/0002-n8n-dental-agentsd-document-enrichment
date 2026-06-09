# 0002 — n8n Dental Agents: Document Enrichment

<!-- TODO: Replace this placeholder with a concise project description -->

## Description

<!-- TODO: Describe what this n8n workflow does, the problem it solves, and the expected inputs/outputs -->

## Prerequisites

- n8n (v1.0+ recommended) — self-hosted or n8n Cloud
- Access to the relevant third-party APIs (see Environment Variables)
- Node.js 18+ (if running n8n locally via npm)

## Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/martinjacksonuk/0002-n8n-dental-agentsd-document-enrichment.git
   cd 0002-n8n-dental-agentsd-document-enrichment
   ```
2. Copy the environment template and fill in your values:
   ```bash
   cp .env .env.local
   ```
3. Import the workflow JSON into your n8n instance via **Settings → Import Workflow**.
4. Configure credentials inside n8n to match the values in your `.env` file.
5. Activate the workflow.

## Environment Variables

All secrets and configuration are stored in `.env` (see `.env` for the full list).  
**Never commit `.env` or any `.env.*.local` file to version control.**

| Variable | Description |
|---|---|
| `N8N_BASE_URL` | Base URL of your n8n instance |
| `N8N_API_KEY` | n8n API key for programmatic access |
| `N8N_WEBHOOK_BASE_URL` | Public base URL for webhook triggers |

## Licence

This project is proprietary software owned by DiGenie Limited.  
See [LICENCE](./LICENCE) for full terms.
