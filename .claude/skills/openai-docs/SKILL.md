---
name: openai-docs
description: Use when working with the OpenAI API, Responses API, ChatGPT Apps SDK, Agents SDK, or choosing an OpenAI model — fetches authoritative, current guidance from the openaiDeveloperDocs MCP server with citations.
---

# OpenAI Docs

Provide authoritative, current guidance from OpenAI developer docs using the
`openaiDeveloperDocs` MCP server. Always prefer this over relying on training
data — OpenAI APIs and models change frequently.

## Tools

- `mcp__openaiDeveloperDocs__search_openai_docs` — search across
  `platform.openai.com` and `developers.openai.com`. Use this first when you
  don't have an exact URL.
- `mcp__openaiDeveloperDocs__fetch_openai_doc` — fetch the full markdown for a
  specific doc page (optionally with an `#anchor` for one section). Always
  fetch before quoting/summarizing — search results are excerpts only.
- `mcp__openaiDeveloperDocs__get_openapi_spec` — fetch the OpenAPI spec. Use
  for exact request/response schemas, parameter names, and required fields.
- `mcp__openaiDeveloperDocs__list_openai_docs` — browse/page through indexed
  docs when you don't have a clear search query yet.

## Workflow

1. `search_openai_docs` for the relevant page(s).
2. `fetch_openai_doc` the most relevant URL (use `anchor` to pull just the
   needed section on long pages).
3. For request/response shapes, parameter names, or required fields, also
   check `get_openapi_spec`.
4. Cite the doc URL(s) used when summarizing for the user.

## OpenAI product map

- **Responses API** — unified endpoint for stateful, multimodal, tool-using
  interactions in agentic workflows. Default choice for new integrations.
- **Chat Completions API** — generate a model response from a list of
  messages; still widely used but Responses API is the forward path.
- **Agents SDK** — toolkit for building agentic apps: tool use, handoffs
  between agents, streaming, tracing.
- **Apps SDK** — build ChatGPT apps via a web component UI + an MCP server
  exposing your app's tools to ChatGPT.
- **Realtime API** — low-latency multimodal/speech-to-speech.
- **File inputs** — `input_file` (PDF, docs, spreadsheets) for the Responses
  API; PDFs get text + page images on vision-capable models.

## Model selection

Model names and capabilities change often — always verify against current
docs before committing to one. `search_openai_docs` for "model" / "latest
model" guidance.
