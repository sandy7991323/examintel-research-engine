---
name: examintel-research-engine
description: >
  Converts uploaded question papers (PDF, image, or text) into comprehensive,
  research-backed, examination-oriented study material written in simple, natural,
  human-written English. Supports 7 execution modes — from full research pipelines
  to quick revision sheets — with mark-wise answer calibration, previous-year
  analysis, syllabus mapping, and multi-format publishing. Default mode is
  FULL RESEARCH when unspecified.
---

# ExamIntel Research Engine

## Overview

This skill takes examination question papers as input and produces study material
that reads like it was written by an experienced college teacher — not generated
by AI. The output is calibrated to exam marking schemes, grounded in syllabus
coverage, and enriched with previous-year question frequency data.

**Default behavior:** When the user uploads a question paper without specifying
a mode, run **FULL RESEARCH MODE**.

---

## Execution Modes

| # | Mode | Trigger Keywords | What It Produces |
|---|------|-----------------|------------------|
| 1 | **FULL RESEARCH** | _default_, "full", "complete" | End-to-end: extraction → research → answers → notes → question bank → PDF |
| 2 | **PAPER SOLUTION** | "solve", "solution", "answers only" | Mark-wise model answers for every question in the paper |
| 3 | **SYLLABUS NOTES** | "notes", "syllabus notes", "topic notes" | Chapter-wise notes mapped to the syllabus, not just the paper |
| 4 | **PREVIOUS YEAR ANALYSIS** | "PYQ", "previous year", "frequency" | Question frequency tables, trend analysis, most-repeated topics |
| 5 | **QUICK REVISION** | "revision", "quick", "last minute" | Condensed bullet-point sheets, mnemonics, key formulas |
| 6 | **QUESTION BANK** | "question bank", "practice", "extra questions" | Additional probable questions with brief answers per topic |
| 7 | **PUBLISHING** | "publish", "export", "PDF" | Re-export existing generated content in a different format |

**Mode selection logic:**
1. Check if the user explicitly named a mode → use it.
2. Check for trigger keywords in the user's message → use the matching mode.
3. No match → default to **FULL RESEARCH**.

---

## Core Workflow Pipeline

Each step has a detailed workflow file in `workflows/`. Execute steps in order;
skip steps not needed by the active mode.

| Step | Workflow File | Modes That Use It | Purpose |
|------|--------------|-------------------|---------|
| 1 | `workflows/01-paper-extraction.md` | ALL | Extract text from uploaded paper (OCR, PDF parse, or manual input) |
| 2 | `workflows/02-paper-identification.md` | ALL | Identify university, subject, semester, year, exam type, marks scheme |
| 3 | `workflows/03-syllabus-research.md` | 1, 3, 5, 6 | Find the matching syllabus online or from known databases |
| 4 | `workflows/04-previous-paper-research.md` | 1, 4, 6 | Gather previous year papers; build question frequency data |
| 5 | `workflows/05-question-analysis.md` | 1, 2, 4, 6 | Classify questions by topic, Bloom's level, marks, repetition count |
| 6 | `workflows/06-deep-topic-research.md` | 1, 2, 3 | Research each topic from textbooks, references, web sources |
| 7 | `workflows/07-answer-generation.md` | 1, 2 | Write mark-calibrated model answers for each question |
| 8 | `workflows/08-topic-notes-generation.md` | 1, 3, 5 | Generate structured topic notes with diagrams and examples |
| 9 | `workflows/09-question-bank-generation.md` | 1, 6 | Create additional probable questions with concise answers |
| 10 | `workflows/10-final-publishing.md` | ALL | Assemble, format, and export the final output |

**Step execution per mode:**

- **FULL RESEARCH:** Steps 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10
- **PAPER SOLUTION:** Steps 1 → 2 → 5 → 6 → 7 → 10
- **SYLLABUS NOTES:** Steps 1 → 2 → 3 → 6 → 8 → 10
- **PREVIOUS YEAR ANALYSIS:** Steps 1 → 2 → 4 → 5 → 10
- **QUICK REVISION:** Steps 1 → 2 → 3 → 8 → 10
- **QUESTION BANK:** Steps 1 → 2 → 3 → 4 → 5 → 6 → 9 → 10
- **PUBLISHING:** Step 10 only (uses previously generated content)

---

## Human Writing Rules

These are non-negotiable. Every piece of generated text must follow them.

### Golden Rules

1. **Write like a college teacher explaining to a student face-to-face.**
   Not like a textbook. Not like a chatbot. Like a person who knows the subject
   and genuinely wants the student to understand it.

2. **Simple vocabulary wins.** Use "use" not "utilize". Use "start" not
   "commence". Use "enough" not "sufficient". If a simpler word exists, pick it.

3. **Explain WHY, not just WHAT.** Don't just state facts — explain the reason
   behind them. "Normalization removes redundancy" is weak. "We normalize
   because without it, updating one copy of a customer's address means hunting
   down every other copy — miss one and your data contradicts itself" is strong.

4. **Use real examples.** Abstract explanations followed by "for example" with
   a concrete scenario. Every concept needs a grounding example a student can
   picture.

5. **Natural sentence flow.** Vary sentence length. Short sentences for impact.
   Longer ones when you need to build a chain of reasoning. Never start three
   paragraphs in a row the same way.

6. **No AI clichés.** The following words and phrases are BANNED:
   - "delve", "crucial", "comprehensive", "in-depth", "it is important to note"
   - "in conclusion", "to summarize", "this is because", "it should be noted"
   - "leverage", "facilitate", "utilize", "commence", "pertaining to"
   - "in the realm of", "plays a vital role", "serves as a cornerstone"
   - "it is worth mentioning", "a myriad of", "in today's world"
   - Any sentence starting with "In the context of..."

7. **Contractions are fine.** "Don't", "isn't", "can't" — these make text
   sound human. Use them naturally (not in every sentence).

8. **Active voice by default.** "The compiler translates source code" beats
   "Source code is translated by the compiler". Passive voice is acceptable
   when the actor is unknown or unimportant.

9. **Transitions should be invisible.** If you need "Furthermore" or "Moreover",
   the paragraph structure is wrong. Good paragraphs flow into each other
   because the ideas connect naturally.

10. **Mark-appropriate depth.** A 2-mark answer is tight and direct. A 10-mark
    answer has structure, examples, and diagrams. Never pad short answers or
    compress long ones. See the mark-wise table below.

---

## Mark-Wise Answer Length Guidelines

| Marks | Target Length | Structure | What to Include |
|-------|-------------|-----------|-----------------|
| 1 | 1–2 sentences | Direct answer | Definition or single fact, nothing more |
| 2 | 3–5 sentences | Brief paragraph | Definition + one example or one-line explanation |
| 3 | 5–7 sentences | Short paragraph | Definition + explanation + example |
| 4 | 8–12 sentences | Structured para | Concept + working + example + edge case or comparison |
| 5 | 0.75–1 page | Intro → Body → Wrap | Concept + detailed explanation + diagram/example + summary line |
| 7 | 1–1.5 pages | Sections with headings | Theory + working + diagram + example + comparison or advantages |
| 10 | 1.5–2.5 pages | Full structured answer | Intro + theory + working + diagram + example + comparison + real-world application |
| 15 | 3–4 pages | Essay-style with sections | All of 10-mark + multiple examples + case study + different perspectives |
| 20 | 4–5 pages | Comprehensive treatment | All of 15-mark + derivations/proofs + extended discussion + future scope |

> [!IMPORTANT]
> These are guidelines, not rigid rules. A well-explained 5-mark answer in
> 0.5 pages beats a padded one in 1.5 pages. Quality over quantity — always.

---

## Output Formats

| Format | File Extension | Use Case | Config Reference |
|--------|---------------|----------|-----------------|
| PDF | `.pdf` | Primary deliverable — print-ready study material | `configs/pdf-settings.yaml` |
| HTML | `.html` | Web-viewable version with interactive elements | `configs/html-settings.yaml` |
| Markdown | `.md` | Editable source, works in any markdown viewer | `configs/markdown-settings.yaml` |
| JSON | `.json` | Structured data export (question bank, analysis) | `schemas/output-schema.json` |
| CSV | `.csv` | Tabular data (frequency tables, topic mapping) | `schemas/csv-schema.json` |

Default output: **Markdown** (always generated) + **PDF** (if PDF tools available).

---

## Capability Detection

Before starting any workflow, detect what tools and capabilities are available.
Adapt the pipeline accordingly — never fail because a tool is missing.

```
CHECK and ADAPT:
├── Internet Access?
│   ├── YES → Use web search for syllabus, PYQ research, topic deep-dives
│   └── NO  → Use only uploaded materials + internal knowledge; skip Steps 3, 4
├── OCR Available? (Tesseract, cloud OCR, or vision model)
│   ├── YES → Extract text from image-based papers automatically
│   └── NO  → Ask user to paste the question paper text manually
├── PDF Libraries? (WeasyPrint, pdfkit, reportlab, or browser print)
│   ├── YES → Generate PDF output
│   └── NO  → Generate Markdown + HTML only; inform user PDF is unavailable
├── File System Write Access?
│   ├── YES → Save outputs to workspace directory
│   └── NO  → Display outputs inline in conversation
└── Image Generation? (matplotlib, mermaid, or image tools)
    ├── YES → Generate diagrams and charts
    └── NO  → Use text-based diagrams (ASCII art) or mermaid code blocks
```

> [!NOTE]
> Log detected capabilities at the start of execution. If a critical capability
> is missing, inform the user and suggest alternatives before proceeding.

---

## Quality Gates

Every output passes through quality checks before delivery. See the referenced
files for detailed checklists.

| Gate | Check File | What It Validates |
|------|-----------|-------------------|
| Language Quality | `quality-checks/language-check.md` | No AI clichés, natural flow, appropriate vocabulary |
| Mark Calibration | `quality-checks/mark-calibration-check.md` | Answer length matches mark allocation |
| Accuracy | `quality-checks/accuracy-check.md` | Facts verified against source material |
| Completeness | `quality-checks/completeness-check.md` | All questions answered, all topics covered |
| Formatting | `quality-checks/formatting-check.md` | Consistent headings, numbering, diagram labels |
| Exam Alignment | `quality-checks/exam-alignment-check.md` | Content matches syllabus, exam pattern, mark scheme |

Run gates in order. Fix failures before proceeding to the next gate.

---

## File References

```
examintel-research-engine/
├── SKILL.md                              ← You are here
├── README.md                             ← Project overview and setup
├── workflows/
│   ├── 01-paper-extraction.md
│   ├── 02-paper-identification.md
│   ├── 03-syllabus-research.md
│   ├── 04-previous-paper-research.md
│   ├── 05-question-analysis.md
│   ├── 06-deep-topic-research.md
│   ├── 07-answer-generation.md
│   ├── 08-topic-notes-generation.md
│   ├── 09-question-bank-generation.md
│   └── 10-final-publishing.md
├── configs/
│   ├── pdf-settings.yaml
│   ├── html-settings.yaml
│   ├── markdown-settings.yaml
│   └── mode-defaults.yaml
├── schemas/
│   ├── output-schema.json
│   ├── csv-schema.json
│   ├── paper-metadata-schema.json
│   └── question-analysis-schema.json
├── templates/
│   ├── answer-template.md
│   ├── notes-template.md
│   ├── revision-sheet-template.md
│   ├── question-bank-template.md
│   └── frequency-table-template.md
├── quality-checks/
│   ├── language-check.md
│   ├── mark-calibration-check.md
│   ├── accuracy-check.md
│   ├── completeness-check.md
│   ├── formatting-check.md
│   └── exam-alignment-check.md
└── examples/
    ├── sample-input-paper.pdf
    ├── sample-output-solution.md
    └── sample-output-notes.md
```

---

## Quick Start

```
1. User uploads a question paper (PDF, image, or text).
2. Skill detects capabilities and selects execution mode.
3. Pipeline runs the steps required for that mode.
4. Quality gates validate every output.
5. Final material is delivered in the requested format.
```

> [!TIP]
> For best results, upload a clear, complete question paper. If the paper is
> an image, make sure it's readable — blurry scans produce bad extractions
> that cascade into bad answers.
