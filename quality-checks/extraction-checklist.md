# Extraction Quality Checklist

Run this checklist after extracting questions from an uploaded paper. Every item must pass or be explicitly flagged.

---

## Paper Metadata Extraction

- [ ] All pages of the document processed (count matches source)
- [ ] University / board name correctly identified
- [ ] Course name extracted (e.g., BCA, B.Tech, MCA)
- [ ] Semester / year identified
- [ ] Subject name extracted exactly as printed
- [ ] Subject code extracted (if present)
- [ ] Examination year identified
- [ ] Examination session identified (May/June, Dec/Jan, etc.)
- [ ] Maximum marks captured
- [ ] Paper duration captured
- [ ] Any special instructions on the cover page captured

## Section Extraction

- [ ] All sections identified (Section A, B, C, etc.)
- [ ] Section-wise marks totals match the paper's maximum marks
- [ ] Section instructions preserved (e.g., "Attempt any 5 out of 8")
- [ ] Compulsory vs. choice-based sections correctly marked

## Question Extraction

- [ ] Every question extracted — total count matches the paper
- [ ] Sub-questions (a, b, c or i, ii, iii) preserved with correct nesting
- [ ] Marks per question correctly recorded
- [ ] Word limits captured where the paper specifies them
- [ ] Internal choices identified (e.g., "OR" between questions)
- [ ] Choice questions linked to their alternatives
- [ ] Original question wording preserved exactly
- [ ] Question numbering matches the original paper
- [ ] Page references recorded for traceability

## Special Content

- [ ] Numerical data in questions preserved accurately (numbers, formulas)
- [ ] Diagram references in questions noted (e.g., "Refer to Figure 1")
- [ ] Code snippets in questions preserved with formatting
- [ ] Tables within questions captured correctly
- [ ] Mathematical notation preserved or transliterated clearly

## Scan / Image Quality

- [ ] Scanned text is readable and correctly OCR'd
- [ ] Any unreadable portions are explicitly flagged (not silently skipped)
- [ ] Flagged portions include page number and approximate location
- [ ] Manual verification is recommended for uncertain OCR results

## Schema Validation

- [ ] Generated JSON validates against `schemas/paper.schema.json`
- [ ] Generated JSON validates against `schemas/question.schema.json`
- [ ] All required fields are populated
- [ ] No duplicate question IDs

---

## When a Check Fails

| Failure | Action |
|---------|--------|
| Missing metadata field | Mark as "unknown" with note, continue processing |
| Question count mismatch | Re-examine the paper, check for missed pages or sub-questions |
| Unreadable portion | Flag with `[UNREADABLE: page X, question Y]` marker |
| Schema validation error | Fix the data structure, do not proceed until valid |
| OCR uncertainty | Include both OCR result and confidence flag |

---

## Completion Criteria

Extraction is complete when:
1. All metadata fields are populated or explicitly marked unknown
2. Question count matches the original paper
3. All sub-questions are captured
4. All internal choices are linked
5. Generated JSON passes schema validation
6. Any unreadable portions are flagged for human review
