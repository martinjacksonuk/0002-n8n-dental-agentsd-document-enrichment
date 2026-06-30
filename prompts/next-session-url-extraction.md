# Next Session: Add URL/Hyperlink Extraction to Vision Path

## Context

The "Dental Document to RAG KB Ingestion" workflow (live ID: `c0eYYmfpLjUNUGZF`) is working end-to-end with a PDF-to-PNG vision extraction path. However, hyperlinks embedded in PDFs are lost during extraction — both the vision OCR (`pdftoppm` + OpenAI) and the standard text extraction (`extractFromFile`) output plain text only, discarding link annotations.

This means cross-references like "Pain pathway" appear in the KB output without their target URLs, reducing the value of the Cross-References section.

## What needs to happen

Add a URL extraction step to the "Convert PDF to PNG" Code node that runs alongside the existing `pdftoppm` conversion. `pdftohtml` (already installed via `poppler-utils` in the custom Docker image) can extract hyperlinks from the PDF's annotation layer.

### Implementation approach

1. **In the "Convert PDF to PNG" Code node** (id: `cc6fff4d-a09e-4c06-b6ca-628ee3fded96`), after the `pdftoppm` call, add a second command:
   ```
   pdftohtml -xml -noframes -nodrm "/tmp/.../input.pdf" "/tmp/.../links"
   ```
   This produces an XML file containing `<a href="...">link text</a>` elements.

2. **Parse the XML output** in the same Code node to extract a deduplicated list of `{ text, url }` pairs. The XML format from `pdftohtml -xml` includes `<link>` elements or inline `<a>` tags depending on the version — the code should handle both.

3. **Add the extracted links to the JSON output** as a new `extracted_links` array alongside the existing `page_images` and `page_count`:
   ```json
   {
     "page_images": [...],
     "page_count": 3,
     "extracted_links": [
       { "text": "Pain pathway", "url": "https://..." },
       { "text": "Endpoint 5", "url": "https://..." }
     ]
   }
   ```

4. **Pass the links through to the KB production stage.** Update the "LLM Stage 3 - Produce KB" node's jsonBody expression to include `extracted_links` in the user message sent to GPT-4o, so the model can populate the Cross-References section with actual URLs.

5. **Update the Module 3 prompt** (`module3ProducePrompt` in Prompt Config, and `prompts/module-3-produce-kb.md`) to instruct the model to use `extracted_links` when populating Cross-References:
   - If `extracted_links` is provided and non-empty, use the URLs in the Internal cross-references and anywhere links are mentioned in the source text
   - Do not invent URLs — only use those present in `extracted_links`

### Important technical notes

- The workflow uses `binaryMode: "separate"`, so binary data must be read via `await this.helpers.getBinaryDataBuffer(0, 'data')` — NOT via `binary.data` (which just contains the string `"filesystem-v2"`).
- The n8n instance runs a hardened Alpine Docker image with no package manager. `poppler-utils` (including `pdftohtml`) is installed via a multi-stage Dockerfile at `/root/n8n-docker-caddy/Dockerfile`.
- The Code node requires `NODE_FUNCTION_ALLOW_BUILTIN=child_process,fs,os,path,zlib` (already set in docker-compose.yml).
- Use `n8n_update_full_workflow` for reliable Code node updates — `patchNodeField` and `removeNode`+`addNode` via `n8n_update_partial_workflow` have been unreliable for replacing jsCode content.
- The non-vision path (standard PDF text extraction via `extractFromFile`) also loses links. Consider whether to add link extraction there too, or only on the vision path for now.

### Files to modify

- **Live workflow** via `n8n_update_full_workflow` (ID: `c0eYYmfpLjUNUGZF`)
- **`workflows/dental-doc-to-rag-kb.json`** — sync local file after live update
- **`prompts/module-3-produce-kb.md`** — add instructions for using `extracted_links`

### Verification

- Run the workflow with the "Swelling pathway" PDF (use_vision: yes) and confirm `extracted_links` contains the Pain pathway URL and endpoint links
- Verify the KB output's Cross-References section includes actual URLs
- Verify the non-vision path still works (use_vision: no) without breaking
