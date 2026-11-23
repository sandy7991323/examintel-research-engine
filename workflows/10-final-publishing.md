# Workflow 10 — Final Publishing

## Title

Final Assembly and Multi-Format Publishing

## Objective

Compile all generated content — answers, notes, question bank, analysis, and
visual resources — into polished, publication-ready output in Markdown, HTML,
JSON, and PDF formats. Run all quality checks before delivery.

---

## Required Inputs

| Input | Source | Required? |
|-------|--------|-----------|
| Paper metadata | `workflows/02-paper-identification.md` output | Yes |
| Question analysis | `workflows/05-question-analysis.md` output | Yes (if available) |
| Model answers | `workflows/07-answer-generation.md` output | Yes (if mode requires) |
| Topic notes | `workflows/08-topic-notes-generation.md` output | Yes (if mode requires) |
| Question bank | `workflows/09-question-bank-generation.md` output | Yes (if mode requires) |
| Topic research data | `workflows/06-deep-topic-research.md` output | Yes |
| Source registry | `workflows/06-deep-topic-research.md` output | Yes |
| Syllabus map | `workflows/03-syllabus-research.md` output | Optional |
| PYQ frequency data | `workflows/04-previous-paper-research.md` output | Optional |
| PDF styling config | `config/default-config.yaml` → `pdf_styling` | Yes |
| Quality check files | `quality-checks/*.md` | Yes |

---

## Step-by-Step Instructions

### Step 1 — Organize Content into Sections

Assemble all generated content into these 10 sections. Skip sections that
don't apply to the active mode.

| # | Section | Contents | Modes |
|---|---------|----------|-------|
| 1 | **Exam Overview** | University, subject, year, exam type, marks scheme, paper structure | ALL |
| 2 | **Syllabus Analysis** | Unit breakdown, topic list, weightage, coverage map | 1, 3, 5, 6 |
| 3 | **Previous Year Analysis** | Frequency tables, trend charts, most-repeated topics, pattern changes | 1, 4 |
| 4 | **Original Paper Solutions** | Mark-wise model answers for every question in the uploaded paper | 1, 2 |
| 5 | **Unit-Wise Notes** | Topic notes organized by syllabus units | 1, 3, 5 |
| 6 | **Question Bank** | Categorized practice questions with source labels | 1, 6 |
| 7 | **Numerical / Practical Solutions** | Worked-out numerical problems, code solutions with output | 1, 2 |
| 8 | **Visual Resources** | All diagrams, flowcharts, tables, and charts collected in one place | ALL |
| 9 | **Quick Revision** | Bullet-point summaries, key formulas, comparison tables, mnemonics | 1, 3, 5 |
| 10 | **References** | Source registry, limitation notes, disclaimers | ALL |

### Step 2 — Generate Markdown Master Document

Create a single Markdown file with:

1. **Title block** with paper metadata (subject, university, year, date).
2. **Table of Contents** with section numbers and anchor links.
3. All 10 sections in order, with consistent heading levels:
   - `# Section Title` for major sections
   - `## Subsection` for topics within a section
   - `### Sub-subsection` for deeper divisions
4. Cross-references between sections as Markdown links.
5. All diagrams as Mermaid code blocks.
6. All tables as Markdown tables.
7. Proper code fencing with language tags for all code blocks.
8. Front matter metadata (optional YAML block at top).

### Step 3 — Generate HTML Document

Convert the Markdown to HTML with these requirements:

#### Semantic Markup

- Use `<article>`, `<section>`, `<nav>`, `<header>`, `<footer>`, `<main>`.
- Use `<h1>` through `<h4>` for headings — never skip levels.
- Use `<figure>` and `<figcaption>` for all diagrams and charts.
- Use `<table>`, `<thead>`, `<tbody>`, `<th>`, `<td>` for data tables.
- Use `<code>` and `<pre>` for inline code and code blocks.
- Use `<abbr>` for abbreviations with `title` attribute.

#### Accessibility Requirements

- [ ] All images and diagrams have descriptive `alt` text.
- [ ] All tables have `<caption>` elements and use `scope` on header cells.
- [ ] The document passes WCAG 2.1 Level AA for color contrast.
- [ ] The heading hierarchy is strictly sequential (no skipped levels).
- [ ] Landmark roles are present: `<nav>` for the TOC, `<main>` for content.
- [ ] All interactive elements (if any) are keyboard-accessible.
- [ ] Language is declared: `<html lang="en">`.
- [ ] Font size is set in relative units (`rem` or `em`), not `px`.

#### Styling

- Embed CSS inline (single-file HTML, no external dependencies).
- Clean, readable typography: system sans-serif stack, 1.6 line height.
- Responsive layout that works on screens from 320px to 1920px.
- Print-friendly `@media print` stylesheet embedded.
- Syntax highlighting for code blocks using CSS-only approach.
- Table styling with alternating row colors and sticky headers.

### Step 4 — Generate JSON Output

Create a JSON file conforming to `schemas/study-material.schema.json`:

#### Validation Requirements for JSON

1. Run the output against the schema and fix every violation.
2. Verify all required fields are present:
   - `material_id`, `paper`, `questions`, `answers` (required by schema).
   - `topics`, `sources`, `question_bank` (include when available).
3. Ensure all `$ref` links resolve correctly:
   - Every `question_id` in `answers` matches a `question_id` in `questions`.
   - Every `topic_id` referenced exists in the `topics` array.
   - Every `source_id` referenced exists in the `sources` array.
4. Validate data types: integers are integers, arrays are arrays, enums
   match allowed values.
5. Run a completeness check: compare the number of questions in JSON
   against the number in the Markdown. They must match.
6. Verify no `null` values exist where the schema requires a string or number.

### Step 5 — Generate PDF Document

If PDF generation tools are available (WeasyPrint, pdfkit, reportlab, or
browser-based print-to-PDF), generate a PDF with these specifications:

#### Page Layout

| Setting | Value |
|---------|-------|
| Page size | A4 (210mm × 297mm) |
| Orientation | Portrait |
| Top margin | 20mm |
| Bottom margin | 20mm |
| Left margin | 18mm |
| Right margin | 18mm |

#### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Body text | Noto Sans (or system sans-serif) | 11pt | 400 (regular) |
| Headings (H1) | Noto Sans | 20pt | 700 (bold) |
| Headings (H2) | Noto Sans | 16pt | 700 |
| Headings (H3) | Noto Sans | 13pt | 600 |
| Code | Fira Code / Consolas / monospace | 10pt | 400 |
| Line height | — | 1.6 | — |

#### Colors

| Element | Color |
|---------|-------|
| Headings | `#1a1a2e` |
| Body text | `#222222` |
| Accent / links | `#0f4c81` |
| Code background | `#f5f5f5` |
| Table header background | `#0f4c81` |
| Table header text | `#ffffff` |
| Table alternating row | `#f9f9f9` |

#### Structural Elements

**Title Page:**
- Subject name (large, centered)
- University name
- Exam type and year
- Generation date
- "ExamIntel Study Material" subtitle

**Table of Contents:**
- Auto-generated with page numbers
- Two levels of depth (sections and major subsections)
- Dotted leaders connecting titles to page numbers

**Headers and Footers:**
- Header: `{Subject Name} — ExamIntel Handbook` (right-aligned)
- Footer: `Page {n} of {total}` (centered)
- No header/footer on the title page

**Page Break Rules:**
- Always break before a new major section (H1).
- Never break between a heading and its first paragraph — keep them together.
- Never leave a heading as the last line on a page (widows).
- Break before a table or diagram if less than 4 lines of content would
  follow it on the current page.
- Code blocks: keep together if ≤ 25 lines. Longer ones may break.

**Table Formatting:**
- Bordered cells with 1px solid `#dddddd`.
- Header row: bold white text on accent background.
- Alternating row colors for readability.
- Cell padding: 8px horizontal, 6px vertical.
- Tables that exceed page width: reduce font to 9pt before allowing overflow.

**Diagram Embedding:**
- Render Mermaid diagrams to SVG or PNG before embedding.
- Center diagrams on the page.
- Max width: 85% of content width.
- Always include the figure caption below the diagram.

### Step 6 — Run Quality Checks

Execute every quality gate from `quality-checks/` in order. Fix all failures
before proceeding to the next gate.

| Gate | File | What It Checks |
|------|------|---------------|
| 1 | `quality-checks/language-check.md` | No AI clichés, natural writing, simple vocabulary |
| 2 | `quality-checks/mark-calibration-check.md` | Answer lengths match mark allocations |
| 3 | `quality-checks/accuracy-check.md` | Facts verified against source material |
| 4 | `quality-checks/completeness-check.md` | All questions answered, all topics covered |
| 5 | `quality-checks/formatting-check.md` | Consistent headings, numbering, diagram labels |
| 6 | `quality-checks/exam-alignment-check.md` | Content matches syllabus, exam pattern, marks |

**For each gate:**
1. Run the check.
2. If it passes → record `PASS` and move to the next.
3. If it fails → record the specific failures, fix them, re-run.
4. After all fixes, re-run the entire gate to confirm.

### Step 7 — Report Limitations Honestly

Add a "Limitations and Disclaimers" section at the end of every output:

- [ ] State whether internet was available during generation.
- [ ] List any topics with limited source coverage.
- [ ] Note any single-source facts that couldn't be cross-verified.
- [ ] Disclose which question bank categories are AI-generated.
- [ ] If PYQ data was incomplete, say so.
- [ ] If the syllabus was inferred (not provided), say so.
- [ ] Recommend the student verify critical facts with their textbook.

---

## Expected Outputs

| Output | Format | File Extension | Description |
|--------|--------|---------------|-------------|
| Master Markdown | Markdown | `.md` | Complete study material in Markdown |
| HTML Document | HTML5 | `.html` | Accessible, styled, single-file HTML |
| Structured Data | JSON | `.json` | Schema-validated structured export |
| Print-Ready PDF | PDF | `.pdf` | Formatted PDF (if tools available) |
| Quality Report | Markdown | `.quality-report.md` | Results of all 6 quality gates |
| Limitation Notes | Markdown (section) | (embedded) | Honest disclosure of all caveats |

File naming follows the pattern from `config/default-config.yaml`:
`{subject}_{type}_{date}.{ext}` — slugified, lowercase, max 120 characters.

---

## Validation Requirements

- [ ] Markdown renders correctly in standard viewers (VS Code, GitHub).
- [ ] HTML passes W3C HTML5 validation with zero errors.
- [ ] HTML meets WCAG 2.1 Level AA accessibility requirements.
- [ ] JSON validates against `schemas/study-material.schema.json` with zero errors.
- [ ] All `$ref` cross-references in JSON resolve correctly.
- [ ] PDF opens in standard readers (Adobe, Chrome, Preview) without errors.
- [ ] PDF page numbers, headers, and footers display correctly.
- [ ] PDF table of contents links to correct pages.
- [ ] All diagrams render correctly in every output format.
- [ ] All 6 quality gates pass.
- [ ] Limitation notes are present and honest.
- [ ] File names follow the naming convention.

---

## Error Handling

| Error | Response |
|-------|----------|
| PDF generation tools unavailable | Generate Markdown + HTML only. Inform the user that PDF requires WeasyPrint, pdfkit, or similar. |
| Mermaid rendering fails | Embed the Mermaid source code as a fenced code block. Add a note that the reader needs a Mermaid-compatible viewer. |
| JSON schema validation fails | Log the specific validation errors. Fix each one. Re-validate until clean. |
| HTML accessibility check fails | Fix the specific violations (missing alt text, skipped headings, etc.). Re-check. |
| File system write access denied | Display all outputs inline in the conversation. Inform the user. |
| Output exceeds reasonable file size (> 50 MB) | Split into multiple files by section. Create an index file linking to each part. |
| A quality gate fails and can't be auto-fixed | Report the failure to the user with the specific issue. Ask for guidance. |
| Content from a previous workflow step is missing | Generate the output with available content. Add a gap note in the limitation section. |
| Font specified in PDF config is not installed | Fall back to system sans-serif. Note the font substitution. |

---

## Completion Criteria

This workflow is **complete** when:

1. At least Markdown output has been generated (the minimum deliverable).
2. HTML output is generated and passes accessibility checks.
3. JSON output validates against the schema with zero errors.
4. PDF is generated (if tools are available) with correct formatting.
5. All 6 quality gates pass.
6. Limitation notes are included and accurate.
7. Files are saved to the output directory with correct naming.
8. The user has been informed which formats were generated and where
   to find them.
9. Any formats that could not be generated are clearly explained
   (tool missing, library unavailable, etc.).
