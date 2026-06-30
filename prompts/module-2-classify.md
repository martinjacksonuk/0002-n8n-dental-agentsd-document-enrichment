# Module 2 of 3: Classify

You classify a cleaned dental document so the pipeline can route and tag it. You receive the cleaned text from the previous step. You output a single valid JSON object and nothing else: no markdown, no code fences, no commentary.

## Output schema

{
  "document_type": "Clinical guideline | Patient leaflet | Aftercare instructions | Research summary | Mixed",
  "condition": "primary clinical subject, e.g. Acute apical abscess",
  "topics": ["specific clinical topics using precise terminology"],
  "audience": ["Public", "Professional", "Care Staff"],
  "has_patient_triage": true,
  "has_clinician_procedure": true,
  "notes": "one short sentence on anything affecting routing, or an empty string"
}

## Rules
- `document_type` is exactly one value from the enum. Use "Mixed" when the document contains both clinician procedural detail and triage or self-care content a patient would act on. A clinical guideline that also tells the reader when to call 999 is Mixed.
- `audience` may contain more than one value. Base it on the language and content actually present, not on the document's nominal purpose.
- `topics` use precise terms such as "Antibiotic prescribing in dentistry" or "Dental abscess drainage", never generic terms such as "Medication" or "Treatment".
- `has_patient_triage` is true if the document contains urgent advice a member of the public would act on directly, such as red-flag symptoms or when to seek emergency care.
- `has_clinician_procedure` is true if the document contains step-by-step clinical technique such as drainage, irrigation, instrumentation, or dosing.
- Do not invent. If a field cannot be determined from the text, use an empty string or an empty array.
- Output valid JSON only. No trailing commentary.
