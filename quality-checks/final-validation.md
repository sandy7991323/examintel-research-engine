# Final Validation Checklist

Master checklist combining all quality gates. Run this before delivering any final study material.

---

## Pre-Validation: Sub-Checklist Status

| Checklist | Status | Notes |
|-----------|--------|-------|
| Extraction Checklist (`extraction-checklist.md`) | [ ] Passed | |
| Research Checklist (`research-checklist.md`) | [ ] Passed | |
| Human Writing Checklist (`human-writing-checklist.md`) | [ ] Passed | |
| Academic Accuracy Checklist (`academic-accuracy-checklist.md`) | [ ] Passed | |

**Rule:** Do not proceed to final publishing until all 4 sub-checklists pass.

---

## Content Completeness

- [ ] **Section 1: Examination Overview** — Present with all metadata fields
- [ ] **Section 2: Syllabus Analysis** — Present with unit-wise breakdown
- [ ] **Section 3: Previous Year Analysis** — Present (or honest "No data available" note)
- [ ] **Section 4: Original Paper Solutions** — All questions answered
- [ ] **Section 5: Unit-Wise Study Notes** — All units covered
- [ ] **Section 6: Question Bank** — Present with source categories
- [ ] **Section 7: Numerical / Practical Solutions** — Present if paper has numerical questions
- [ ] **Section 8: Visual Learning Resources** — Diagrams included where useful
- [ ] **Section 9: Quick Revision Material** — Definitions, comparisons, formulas, key concepts
- [ ] **Section 10: Research References** — Source list with verification status

## Document Structure

- [ ] Table of contents matches actual section headings
- [ ] Heading hierarchy is consistent (H1 → H2 → H3, never skipped)
- [ ] All internal cross-references point to correct sections
- [ ] No orphaned headings (heading at page bottom, content on next page)
- [ ] No broken diagram references

## PDF Publishing Checks

- [ ] Title page is clean — no QR codes, no promotional content
- [ ] Page numbers are present and sequential
- [ ] Headers show subject name and current unit
- [ ] Footers show page number and course info
- [ ] Margins are consistent (18-20mm on all sides)
- [ ] Diagrams are readable at print size
- [ ] Tables fit within page boundaries (no text cutoff)
- [ ] Code blocks have proper formatting and syntax highlighting
- [ ] Font rendering is consistent throughout
- [ ] No blank pages unless intentional

## HTML Publishing Checks

- [ ] HTML uses semantic markup (proper h1-h6, p, ul, ol, table, figure)
- [ ] All images have alt text
- [ ] Tables have header rows marked with `<th>`
- [ ] Code blocks use `<pre><code>` with language class
- [ ] Links are functional
- [ ] Page is readable without CSS (content makes sense structurally)

## JSON Publishing Checks

- [ ] JSON validates against `schemas/study-material.schema.json`
- [ ] All required fields are populated
- [ ] No null values where data exists
- [ ] Array lengths match expected counts
- [ ] UTF-8 encoding used throughout
- [ ] File is parseable by standard JSON parsers

## Markdown Publishing Checks

- [ ] Heading levels are correct
- [ ] Code blocks have language identifiers
- [ ] Tables render correctly in standard Markdown viewers
- [ ] Mermaid diagrams have proper syntax
- [ ] Links use relative paths where appropriate

## Limitations Disclosure

- [ ] Research limitations section is present in the final output
- [ ] Any tools that were unavailable are noted
- [ ] Any topics with limited research are identified
- [ ] Confidence levels are stated for research findings
- [ ] No false claims of completeness

---

## Final Sign-Off Summary

```
Material ID: {{ID}}
Version: {{VERSION}}
Generated: {{DATE}}

Paper: {{UNIVERSITY}} / {{COURSE}} {{SEMESTER}} / {{SUBJECT}} ({{CODE}})
Exam: {{YEAR}} {{SESSION}}

Statistics:
- Total Questions Extracted: {{count}}
- Total Questions Answered: {{count}}
- Total Topics Covered: {{count}}
- Total Study Notes Pages: {{count}}
- Total Question Bank Items: {{count}}
- Total Research Sources: {{count}}
- Syllabus Coverage: {{percentage}}%

Quality Gates:
- Extraction: {{PASS/FAIL}}
- Research: {{PASS/FAIL}}
- Writing Quality: {{PASS/FAIL}}
- Academic Accuracy: {{PASS/FAIL}}
- Publishing: {{PASS/FAIL}}

Overall Status: {{READY / NEEDS REVIEW}}

Known Limitations:
1. {{Limitation}}
2. {{Limitation}}
```

---

## Completion Criteria

The study material is ready for delivery when:
1. All 4 sub-checklists pass
2. All 10 content sections are present
3. At least one output format passes its publishing checks
4. Limitations are honestly disclosed
5. Final sign-off summary is complete
