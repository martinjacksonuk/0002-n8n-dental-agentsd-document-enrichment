# 0002 — n8n Dental Agents: Document Enrichment

## Description

This workflow is triggered by new/updated records in an Airtable table, where each record holds
the Google Doc/Drive file ID of a dental practice document (PDF, DOCX, legacy DOC, TXT). It
downloads the referenced file from Google Drive and produces a single retrieval-optimised
markdown knowledge-base (KB) document per source file, ready for downstream chunking/embedding
into a RAG vector store (out of scope here).

Each document passes through three sequential, independently re-runnable LLM stages:

1. **Clean** — verbatim clinical clean-up of the extracted text (preserves doses, percentages,
   named drugs/irrigants exactly as written).
2. **Classify** — returns strict, schema-validated JSON (condition title, document type,
   audience-tagged sections, clinical figures, named products) via OpenAI Structured Outputs.
3. **Produce KB** — combines the cleaned text + classification into a single markdown file with
   YAML frontmatter and numbered sections, written in UK English with no em dashes.

A single malformed or unsupported document is routed to a quarantine path (an `.error.json`
file in a Drive folder) instead of halting the batch.

The workflow file lives at [`workflows/dental-doc-to-rag-kb.json`](workflows/dental-doc-to-rag-kb.json)
and has been deployed to the n8n instance as **"Dental Document to RAG KB Ingestion"**
(workflow ID `c0eYYmfpLjUNUGZF`, currently **inactive** pending the setup steps below).

## Architecture

```text
Airtable Trigger ───────┐
                        ├─> Prompt Config ─> Download File ─> Detect File Type ─> Route by File Type
Manual Trigger (Test) ──┘                                                              │
                                                                    ┌──────────┬────────┼────────┬──────────────┐
                                                                  pdf        docx      txt       doc        unsupported
                                                                    │          │        │         │               │
                                                              Extract PDF  Extract   Extract    DOC Stub    Unsupported Stub
                                                                    │       DOCX      TXT          │               │
                                                            Is Scanned PDF?    │        │           └──> Quarantine Logger <──┘
                                                              │true   │false   │        │
                                                       PDF Vision      └───────┴────────┴──> Pre-strip Web Chrome
                                                       Extract                                       │
                                                              │                              LLM Stage 1 - Clean ──(error)──> Quarantine Logger
                                                       Store Vision Text                             │
                                                              └──────────────────────────────> Store Cleaned Text ──(error)──> Quarantine Logger
                                                                                                      │
                                                                                          LLM Stage 2 - Classify ──(error)──> Quarantine Logger
                                                                                                      │
                                                                                       Parse Classification JSON ──(error)──> Quarantine Logger
                                                                                                      │
                                                                                          LLM Stage 3 - Produce KB ──(error)──> Quarantine Logger
                                                                                                      │
                                                                                            Store KB Markdown ──(error)──> Quarantine Logger
                                                                                                      │
                                                                                          Convert KB to File ─> Upload KB to Drive

                                                                          Quarantine Logger ─> Convert Error to File ─> Upload Error to Drive
```

> Note: `Detect File Type`, `Extract PDF`, `Extract DOCX`, `Extract TXT`, and `Store Vision Text`
> all have `onError: continueErrorOutput` and route failures directly to `Quarantine Logger`
> (omitted from the diagram above for readability).

## Model Assignments (placeholders — verify before production)

| Stage | Spec name | API model string used | Notes |
| --- | --- | --- | --- |
| Clean | GPT-5.4 Mini | `gpt-4o-mini` | Cheap/fast; verbatim clean-up only |
| Classify | GPT-5.4 Nano | `gpt-4o-mini` | Structured Outputs (`response_format.json_schema`, `strict: true`) |
| Produce KB | GPT-5.4 / 5.5 | `gpt-4o` | Highest quality, authors the final markdown |
| Scanned PDF OCR | (vision) | `gpt-4o` | Only used when a PDF has no extractable text layer |

`gpt-4o-mini` / `gpt-4o` are placeholders chosen because the GPT-5.4 family strings could not
be verified against the OpenAI model reference at build time. **Update the `model` field in
the four HTTP Request nodes (`LLM Stage 1 - Clean`, `LLM Stage 2 - Classify`,
`LLM Stage 3 - Produce KB`, `PDF Vision Extract`) once the correct model IDs are confirmed.**

## Native vs HTTP Request decisions

- **All three LLM stages use `HTTP Request` nodes** against `https://api.openai.com/v1/chat/completions`
  (and `/v1/responses` for scanned-PDF OCR), not the native OpenAI node. The native
  `n8n-nodes-base.openAi` node does not expose `response_format: { type: "json_schema", strict: true }`,
  which the Classify stage requires. Using HTTP Request consistently across all three stages
  keeps prompt construction, error handling, and credential usage uniform.
- Each HTTP Request node builds its body with `JSON.stringify({...})` inside the expression,
  so prompt text containing quotes, newlines, or backticks doesn't need manual escaping.
- Static system prompt is always the first message and the variable document content is last,
  to maximise OpenAI prompt-cache hits.
- Text extraction (PDF/DOCX/TXT) is done in `Code` nodes rather than a dedicated "Extract from
  File" node — no such native node exists in this n8n instance's node registry (confirmed via
  the n8n-mcp node search).

## Prerequisites

- n8n (v1.0+) — self-hosted or n8n Cloud
- **`NODE_FUNCTION_ALLOW_EXTERNAL=mammoth,pdf-parse`** set as an environment variable on the n8n
  instance. The `Extract DOCX` node calls `require('mammoth')` and `Extract PDF` calls
  `require('pdf-parse')` — both are bundled with n8n's dependencies but `require()` of npm
  packages inside Code nodes is blocked unless explicitly allowlisted. Without this, DOCX and
  PDF extraction will throw immediately. The extraction Code nodes have
  `onError: continueErrorOutput`, so a missing allowlist will route the affected document to
  quarantine rather than failing the whole execution — but every document will be quarantined
  until the allowlist is set, so confirm this before relying on automatic runs.
- A Google Drive credential (OAuth2 or Service Account) with access to the source files, output
  folder, and quarantine folder.
- An Airtable credential (API key, access token, or OAuth2) with access to the base/table that
  lists documents to process.
- An OpenAI API credential (`openAiApi` type) for the four HTTP Request LLM nodes.

## Setup

1. **Attach credentials**: in the n8n editor, open each node listed below and select/create the
   credential:
   - `Airtable Trigger` → Airtable credential
   - `Download File`, `Upload KB to Drive`, `Upload Error to Drive` → Google Drive credential
   - `LLM Stage 1 - Clean`, `LLM Stage 2 - Classify`, `LLM Stage 3 - Produce KB`,
     `PDF Vision Extract` → OpenAI API credential
2. **Configure the Airtable Trigger** (`Airtable Trigger` node) — replace the placeholder
   values:
   - `baseId.value` = the Airtable base ID containing the document list table
   - `tableId.value` = the table ID/name listing documents to process
   - `triggerField` = a Created Time / Last Modified Time field in that table (required by
     the Airtable Trigger to detect new/changed records)
   - Confirm the table has a field named **"Google Doc ID"** containing the Google
     Drive/Docs file ID for each document — `Download File` reads this field via
     `$json.fields['Google Doc ID']`. If your field is named differently, update the
     expression on `Download File` → `fileId.value` to match.
3. **Set folder IDs** — replace the placeholder strings with real Google Drive folder IDs:
   - `Upload KB to Drive` → `folderId.value` = `OUTPUT_FOLDER_ID`
   - `Upload Error to Drive` → `folderId.value` = `QUARANTINE_FOLDER_ID`
4. **Paste the module prompts** into the `Prompt Config` Set node (three fields, each currently
   `TODO: paste module-N-...md contents here`):
   - `module1CleanPrompt` ← contents of `module-1-clean.md`
   - `module2ClassifyPrompt` ← contents of `module-2-classify.md`
   - `module3ProducePrompt` ← contents of `module-3-produce-kb.md`
5. **Classification schema** — the JSON schema used in `LLM Stage 2 - Classify`'s
   `response_format.json_schema` is currently the placeholder in
   [`prompts/classification-schema.json`](prompts/classification-schema.json), inlined directly
   into the node's expression. If you have a different/real schema, update both the file (for
   reference) and the inlined `schema` object in the `LLM Stage 2 - Classify` node body.
6. **Verify model strings** against the OpenAI model reference (see Model Assignments above)
   and update the four HTTP Request nodes if needed.
7. **Confirm `NODE_FUNCTION_ALLOW_EXTERNAL`** is set on the n8n host (see Prerequisites).
8. **Test run**: set `Set Test File ID` → `id` to a real Google Drive file ID (e.g. the file ID
   of `Acute_apical_abscess.pdf`), then execute the workflow from `Manual Trigger (Test)`.
9. Once a manual test run produces a correct KB markdown file in the output folder, **activate**
   the workflow so `Airtable Trigger` starts polling the configured Airtable table
   automatically.

## Running

- **Automatic**: any new/updated record in the configured Airtable table (with a populated
  "Google Doc ID" field) triggers a run for that document (PDF/DOCX/DOC/TXT).
- **Manual / debugging**: use `Manual Trigger (Test)` → `Set Test File ID` to run against one
  known file. Enable **Save manual executions** in n8n settings to inspect each node's output
  (`raw_text`, `cleaned_text`, classification JSON, `kb_markdown`) per stage.
- **Re-running a single stage**: because each stage reads its inputs via `$('Node Name')`
  references rather than relying purely on immediate-predecessor output, you can pin/replay
  data on `Pre-strip Web Chrome`, `Store Cleaned Text`, or `Parse Classification JSON` to
  re-run only the downstream stages during debugging.
- **Quarantine**: any extraction failure, malformed/unsupported file, or LLM stage error
  produces `<original_filename>.error.json` in `QUARANTINE_FOLDER_ID` containing the original
  filename, error message, and timestamp. The batch is not halted.

## Known Limitations / Open Items

- **`.doc` (legacy binary Word) is stubbed**, not implemented. `DOC Stub` routes straight to
  quarantine with a message explaining that LibreOffice-based conversion
  (`libreoffice --headless --convert-to docx`) would need to be wired in via an
  `Execute Command` node, once LibreOffice availability on the host is confirmed.
- **`require('mammoth')` / `require('pdf-parse')`** depend on `NODE_FUNCTION_ALLOW_EXTERNAL`
  being set on the n8n host (see Prerequisites). If this cannot be enabled, the DOCX/PDF
  extraction Code nodes will need to be replaced with an alternative (e.g. an `Execute Command`
  node calling `pdftotext`/`mammoth` CLI, or a community extraction node).
- **Scanned PDFs** (no extractable text layer) are routed to `PDF Vision Extract`, which sends
  the PDF as base64 `input_file` data to the OpenAI Responses API (`/v1/responses`). This is
  more expensive and slower than born-digital extraction — confirm the chosen vision model
  supports direct PDF input.
- **Sample acceptance test** (`Acute_apical_abscess.pdf`) has not been uploaded to Drive or run
  end-to-end — this is required before the workflow can be considered verified against the
  acceptance criteria (verbatim figure preservation, audience tagging, schema-valid classify
  output, DOCX/TXT equivalence).

## Out of Scope

Chunking and embedding the produced markdown into a vector store is handled by a separate
downstream workflow.

## Licence

This project is proprietary software owned by DiGenie Limited.
See [LICENCE](./LICENCE) for full terms.
