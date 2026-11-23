# Workflow 01 — Paper Extraction

## Title
**Extract Questions, Metadata, and Structure from an Uploaded Question Paper**

## Objective
Accept an uploaded question paper (PDF, image, or pasted text), extract every question along with its marks, numbering, and special instructions, and produce structured JSON output conforming to `paper.schema.json` and `question.schema.json`. This is the foundational step — every downstream workflow depends on its output.

## Used By Modes
ALL modes (Full Research, Paper Solution, Syllabus Notes, Previous Year Analysis, Quick Revision, Question Bank, Publishing).

---

## Required Inputs

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| Uploaded file | PDF, image (JPG/PNG/TIFF), or pasted text | YES | The question paper to extract |
| Source filename | string | YES (auto-detected) | Original filename for `source_file` field |

## Expected Outputs

| Output | Format | Schema | Description |
|--------|--------|--------|-------------|
| Paper metadata object | JSON | `schemas/paper.schema.json` | University, course, semester, subject, year, sections, etc. |
| Question objects array | JSON | `schemas/question.schema.json` | One object per question/sub-question |
| Extraction log | Plain text | — | Record of method used, confidence, and any issues |

---

## Step-by-Step Instructions

### Step 1: Determine Document Type

1. Check the file extension and MIME type of the uploaded document.
2. Classify into one of these categories:
   - **TEXT**: User pasted the question paper as plain text in the chat.
   - **PDF_DIGITAL**: A digitally-created PDF with selectable text (copy-paste works).
   - **PDF_SCANNED**: A PDF containing scanned images — no selectable text.
   - **IMAGE_PRINTED**: A photograph or scan of a printed paper.
   - **IMAGE_HANDWRITTEN**: A photograph of a handwritten question paper.
   - **MULTI_FILE**: Multiple files uploaded — may contain several papers.
3. Record the detected type in the extraction log.

**How to detect PDF_DIGITAL vs. PDF_SCANNED:**
- Try to extract text from the first page of the PDF using a text extraction tool.
- If meaningful text is returned (more than 20 words), it's PDF_DIGITAL.
- If the extracted text is empty, garbled, or fewer than 20 words, it's PDF_SCANNED.

### Step 2: Extract Raw Text

Based on the document type from Step 1, follow the appropriate procedure:

#### 2A — TEXT (pasted text)
1. Use the text exactly as provided by the user.
2. Set `extraction_method` to `"manual"`.
3. Set `extraction_confidence` to `1.0`.

#### 2B — PDF_DIGITAL
1. Parse the PDF using available PDF text extraction tools.
2. Extract text page by page, preserving page breaks.
3. Record which page each piece of text came from.
4. Set `extraction_method` to `"pdf-parse"`.
5. Set `extraction_confidence` to `0.95`.

#### 2C — PDF_SCANNED
1. Check if OCR capability is available (Tesseract, cloud OCR, or vision model).
2. If OCR is available:
   - Convert each PDF page to an image.
   - Run OCR on each page image.
   - Collect the text output page by page.
   - Set `extraction_method` to `"ocr"`.
   - Set `extraction_confidence` to `0.75` (adjust based on OCR quality).
3. If OCR is NOT available:
   - Ask the user to paste the question paper text manually.
   - Set `extraction_method` to `"manual"`.
   - Inform the user: "The uploaded file is a scanned PDF. OCR tools aren't available, so please paste the question paper text."

#### 2D — IMAGE_PRINTED
1. If a vision model is available (e.g., multimodal LLM):
   - Send the image directly to the vision model with the prompt: "Extract all text from this question paper image. Preserve the exact numbering, marks, section labels, and formatting."
   - Set `extraction_method` to `"vision"`.
   - Set `extraction_confidence` to `0.80`.
2. If only OCR is available:
   - Run OCR on the image.
   - Set `extraction_method` to `"ocr"`.
   - Set `extraction_confidence` to `0.70`.
3. If neither is available:
   - Ask the user to paste the text manually.

#### 2E — IMAGE_HANDWRITTEN
1. If a vision model is available:
   - Send the image to the vision model with the prompt: "This is a handwritten question paper. Extract all text carefully, preserving question numbers, marks, and section labels. Flag any words you cannot read with [UNREADABLE]."
   - Set `extraction_method` to `"vision"`.
   - Set `extraction_confidence` to `0.60`.
2. If only OCR is available:
   - Warn: "Handwritten text OCR is unreliable. Results will need manual review."
   - Run OCR. Set `extraction_confidence` to `0.40`.
3. If neither is available:
   - Ask the user to type out the questions manually.

#### 2F — MULTI_FILE (Multiple Files)
1. Count the number of files.
2. Check if they form one paper split across pages (e.g., `page1.jpg`, `page2.jpg`) or multiple distinct papers.
3. If one paper split across files:
   - Sort files by name/number.
   - Extract text from each file in order.
   - Concatenate into a single text stream.
4. If multiple distinct papers:
   - Process each paper independently through this entire workflow.
   - Generate separate JSON outputs for each paper.

### Step 3: Extract Paper Metadata

From the raw text, extract every metadata field. Search the **first page** and **header area** for these fields:

| Field | Where to Look | Patterns to Match |
|-------|--------------|-------------------|
| `university` | Top of page 1, header | Full university name, logo text, or abbreviation |
| `course` | Below university name | "B.Tech", "MCA", "BCA", "M.Sc", etc. |
| `semester` | Near course name | "Semester: V", "Sem-3", "Third Semester", Roman numerals |
| `subject` | Prominent position, often bold | Paper/subject title |
| `subject_code` | Near subject name | Alphanumeric code like "KCS-501", "BCS-042", "RCS-603" |
| `exam_year` | Header or footer | 4-digit year: "2023", "2023-24" |
| `exam_session` | Near year | "Dec", "May", "Odd Sem", "Even Sem", "Supplementary" |
| `max_marks` | Header area | "Max. Marks: 100", "Total Marks: 70" |
| `duration_minutes` | Header area | "Time: 3 Hours" → convert to 180 minutes |

**Rules:**
- If a field is not found, set it to `null` — never guess.
- If multiple possible values exist (e.g., two different years printed), log the ambiguity and pick the most likely value.
- Generate a unique `paper_id` using the pattern: `{university_abbr}_{subject_code}_{exam_year}_{exam_session}` (e.g., `AKTU_KCS501_2023_dec`). If parts are unknown, use `UNK`.

### Step 4: Parse Sections and General Instructions

1. Identify paper-level instructions (usually at the top, before Section A). Common patterns:
   - "Attempt all sections."
   - "All questions are compulsory."
   - "Internal choice is given in each question."
   - "Draw neat diagrams wherever necessary."
   - "Assume suitable data if not given."
2. Identify sections. Common patterns:
   - "Section A", "Section B", "Section C" (or "SECTION – A")
   - "Part I", "Part II", "Part III"
   - "Group A", "Group B"
3. For each section, extract:
   - `section_name`: The label (e.g., "Section A").
   - `instructions`: Section-specific instructions (e.g., "Attempt any TWO questions from this section. Each question carries 10 marks.").
4. Store sections in order as they appear in the paper.

### Step 5: Extract Questions

For each section, extract every question. Follow these rules precisely:

1. **Identify question boundaries.** A new question starts when you see a new question number (1, 2, 3... or Q1, Q2... or i, ii, iii...).

2. **For each question, capture:**
   - `question_number`: Main number as printed (e.g., 1, 2, 3).
   - `sub_question`: Letter or sub-number if present (e.g., "a", "b", "i", "ii").
   - `question_text`: The full text of the question. Preserve it exactly — don't paraphrase.
   - `marks`: The mark allocation. Look for patterns like "(5)", "[5 marks]", "5M", "Marks: 5".
   - `word_limit`: If specified (e.g., "in 50 words", "within 200 words").
   - `is_compulsory`: Based on section instructions.
   - `special_instructions`: Any per-question instructions (e.g., "Draw a diagram", "Use examples").
   - `page_reference`: Which page of the source document this question appears on.

3. **Handle sub-questions (nested questions):**
   - If Q1 has parts (a), (b), (c) — create a separate question object for each part.
   - Set the `question_number` to the parent number and `sub_question` to the part label.
   - Each sub-question gets its own marks allocation.
   - If sub-question marks aren't individually listed but the parent says "5 × 2 = 10", assign 2 marks to each of the 5 sub-questions.

4. **Handle internal choices (OR questions):**
   - When you see "OR" or "ALTERNATIVELY" between two questions, they are internal choices.
   - Set `has_internal_choice` to `true` on both questions.
   - In `choice_questions`, link each question to its alternative(s) by `question_id`.
   - Both the question and its OR alternative must be fully extracted.

5. **Handle table-format papers:**
   - Some papers present questions in a table (columns: Q.No., Question, Marks, CO, BL).
   - Parse each row as a separate question.
   - Ignore columns that aren't relevant to the student (like CO, BL, PO mappings) but log them in the extraction log.

6. **Generate `question_id`** using the pattern: `{paper_id}_Q{number}_{sub}` (e.g., `AKTU_KCS501_2023_dec_Q1_a`).

### Step 6: Handle Unreadable Portions

1. If any part of the text could not be reliably extracted (blurry, cut off, smudged), add it to the `unreadable_portions` array.
2. Format each entry as: `"Page {N}: {description of what's unreadable}"` (e.g., `"Page 2: Question 5b text is partially cut off after 'Explain the concept of'"`)
3. If a question's text is partially unreadable, include whatever IS readable in `question_text` and append `[PARTIAL — text unclear after this point]`.
4. If an entire question is unreadable, create a placeholder: `question_text: "[UNREADABLE — Question {N} could not be extracted from the source document]"`.
5. After extraction, if `unreadable_portions` has any entries, inform the user and ask if they can provide the missing text.

### Step 7: Calculate Totals and Cross-Check

1. Count the total number of question objects created → set `total_questions`.
2. Sum the marks of all compulsory questions. Compare against `max_marks`:
   - If they match → good.
   - If the sum of compulsory questions is less than `max_marks`, some questions likely have choice — verify `internal_choices` is `true`.
   - If the sum exceeds `max_marks`, there are internal choices or section-level choices you may have missed. Re-examine the instructions.
3. Set `internal_choices` to `true` if any question has `has_internal_choice: true`.
4. Log the cross-check results.

### Step 8: Assemble JSON Output

1. Build the paper metadata object conforming to `paper.schema.json`:
   ```json
   {
     "paper_id": "...",
     "university": "...",
     "course": "...",
     "semester": "...",
     "subject": "...",
     "subject_code": "...",
     "exam_year": 2023,
     "exam_session": "dec",
     "max_marks": 100,
     "duration_minutes": 180,
     "sections": [ ... ],
     "total_questions": 25,
     "internal_choices": true,
     "source_file": "original-filename.pdf",
     "extraction_method": "pdf-parse",
     "extraction_confidence": 0.95,
     "unreadable_portions": []
   }
   ```

2. Build the questions array — one object per question conforming to `question.schema.json`.

3. Validate the JSON against the schemas. Check:
   - All `required` fields are present.
   - Enum values are valid (e.g., `exam_session` is one of the allowed values).
   - `extraction_confidence` is between 0 and 1.
   - `exam_year` is between 1900 and 2100.
   - Every `question_id` is unique.

### Step 9: Present Extraction Summary to User

Display a summary for the user to verify:

```
📄 Paper Extraction Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━
University:    [extracted value or "Not found"]
Course:        [extracted value or "Not found"]
Subject:       [extracted value]
Subject Code:  [extracted value or "Not found"]
Year/Session:  [year] / [session]
Max Marks:     [value]
Duration:      [value] minutes

Sections Found: [count]
  - Section A: [N] questions
  - Section B: [N] questions
  - Section C: [N] questions

Total Questions Extracted: [count]
Internal Choices Found:    [Yes/No]
Extraction Method:         [method]
Confidence:                [score]%

⚠️  Issues: [list any unreadable portions or ambiguities]
```

Ask the user: "Does this look correct? Should I fix anything before proceeding?"

---

## Validation Checklist

Run through this checklist before marking the workflow as complete. Every item must pass.

- [ ] **Paper ID generated** — Unique, follows the naming pattern.
- [ ] **University name extracted** — Or explicitly marked as "Not found".
- [ ] **Subject extracted** — This is a required field; extraction cannot proceed without it.
- [ ] **Exam year extracted** — Required field; must be a 4-digit integer.
- [ ] **At least one section exists** — The `sections` array has ≥ 1 entry.
- [ ] **Every question has `question_id`** — Unique across the entire paper.
- [ ] **Every question has `question_text`** — Even if partial (with `[PARTIAL]` marker).
- [ ] **Every question has `marks`** — Integer ≥ 0.
- [ ] **Sub-questions correctly nested** — Parent number and sub-label are set.
- [ ] **Internal choices linked** — OR questions reference each other in `choice_questions`.
- [ ] **Marks cross-check done** — Sum of compulsory marks matches or is compatible with `max_marks`.
- [ ] **Unreadable portions logged** — Any extraction failures are recorded.
- [ ] **JSON validates against schema** — Both `paper.schema.json` and `question.schema.json`.
- [ ] **Extraction summary shown to user** — User has had a chance to verify.

---

## Error Handling and Fallback Procedures

| Error | Cause | Fallback |
|-------|-------|----------|
| File cannot be opened | Corrupted file, unsupported format | Ask the user to re-upload or paste text manually |
| OCR returns gibberish | Poor scan quality, low resolution | Ask the user to provide a clearer scan or paste text |
| No questions detected | Unusual paper format, language issue | Ask the user to point out where questions start |
| Marks don't add up | Missing questions, misread marks, missed OR choices | Re-examine the paper; ask the user to confirm mark scheme |
| Multiple papers in one file | Combined PDF | Split and process each paper independently |
| Non-English paper | Paper in Hindi, mixed language | Extract as-is; note the language in the log; translate if capable |
| Table-format paper | Questions in tabular layout | Parse row-by-row instead of sequential text |
| Vision model unavailable | No multimodal capability | Fall back to OCR; if OCR also unavailable, request manual input |

---

## Completion Criteria

This workflow is **COMPLETE** when:

1. A valid `paper.schema.json` object exists with all required fields populated.
2. A valid `question.schema.json` array exists with one entry per question.
3. The extraction summary has been shown to the user.
4. All items in the validation checklist pass.
5. Any unreadable portions are documented and the user has been notified.

**Pass this output to:** `02-paper-identification.md`
