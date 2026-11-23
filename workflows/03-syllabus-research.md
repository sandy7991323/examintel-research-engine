# Workflow 03 — Syllabus Research

## Title
**Find and Structure the Official Syllabus for the Identified Paper**

## Objective
Locate the official syllabus for the university, course, subject, and year identified in Workflow 02. Extract unit-wise topic breakdowns, prescribed books, and reference books. Map every question from the paper to its corresponding syllabus unit. Identify gaps where the paper asks about topics not in the syllabus (or vice versa). Output structured JSON conforming to `syllabus.schema.json`.

## Used By Modes
Full Research (1), Syllabus Notes (3), Quick Revision (5), Question Bank (6).

---

## Required Inputs

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| Verified paper metadata | JSON | YES | Output from Workflow 02 (university, course, subject, year, etc.) |
| University profile | JSON | YES | From Workflow 02 (official website URL, type, etc.) |
| Questions array | JSON | YES | From Workflow 01 |
| Internet access | boolean | Preferred | Needed for online syllabus search |
| User-provided syllabus | PDF/text | Optional | If the user uploaded their own syllabus |

## Expected Outputs

| Output | Format | Schema | Description |
|--------|--------|--------|-------------|
| Syllabus object | JSON | `schemas/syllabus.schema.json` | Full structured syllabus |
| Question-to-unit mapping | JSON array | — | Each question linked to its syllabus unit and topic |
| Coverage report | Structured text | — | Which units are covered by the paper and which are not |
| Syllabus research log | Plain text | — | Sources consulted, search queries used, what was found/not found |

---

## Step-by-Step Instructions

### Step 1: Check for User-Provided Syllabus

1. Before searching online, check if the user has already provided a syllabus document (PDF, image, or text).
2. If YES:
   - This is the **highest priority source** (see `config/research-priority.yaml`, priority 1: official_university).
   - Parse it directly (go to Step 5).
   - Set `verification_status` to `"verified"`.
   - Set `source_url` to `"user-provided"`.
   - Still perform the online search (Step 2-4) to cross-reference, but do NOT override the user-provided syllabus.
3. If NO:
   - Proceed to online search (Step 2).

### Step 2: Search for Official Syllabus Online

Execute searches in the following priority order. Stop as soon as you find a matching syllabus, but record all search attempts in the research log.

#### Search Query Templates

Use these search queries, substituting values from the verified metadata:

1. **Primary query (most specific):**
   ```
   "{university_full_name}" "{subject_code}" syllabus {exam_year}
   ```
   Example: `"Dr. A.P.J. Abdul Kalam Technical University" "KCS-501" syllabus 2023`

2. **Secondary query (without year):**
   ```
   "{university_abbreviation}" "{subject_code}" syllabus
   ```
   Example: `"AKTU" "KCS-501" syllabus`

3. **Tertiary query (subject name instead of code):**
   ```
   "{university_abbreviation}" "{subject_name}" syllabus "{course}"
   ```
   Example: `"AKTU" "Design and Analysis of Algorithms" syllabus "B.Tech"`

4. **Broad query (university + course):**
   ```
   "{university_abbreviation}" {course} semester {semester_number} syllabus
   ```
   Example: `"AKTU" B.Tech semester 5 syllabus`

5. **Site-restricted query (target official domain):**
   ```
   site:{university_domain} {subject_code} syllabus
   ```
   Example: `site:aktu.ac.in KCS-501 syllabus`

#### Priority Domains to Check

Search results from these domains should be prioritized:

| Priority | Domain Pattern | Description |
|----------|---------------|-------------|
| 1 | `*.ac.in`, `*.edu.in`, `*.edu` | Official university/college domains |
| 2 | `ugc.ac.in`, `aicte-india.org` | Regulatory body websites |
| 3 | `aktu.ac.in`, `rgpv.ac.in`, etc. | Known university portals |
| 4 | Academic resource aggregators | Sites that mirror official syllabi |

#### What to look for in search results

- PDF files titled "Syllabus" or "Curriculum" on the university domain.
- Pages listing course structure with unit-wise breakdowns.
- Scheme documents that show subject codes per semester.

### Step 3: Download and Verify the Syllabus

1. When you find a potential syllabus document:
   - Check that the subject code or subject name matches.
   - Check that the course (B.Tech, MCA, etc.) matches.
   - Check the applicable year — many universities revise syllabi periodically.
2. **Year matching rules:**
   - If the exam year is 2023 and the syllabus says "Effective from 2020", it applies (unless a newer syllabus replaced it).
   - If you find syllabi for multiple years, pick the one that was active during the exam year.
   - Common revision cycles: AKTU revises every 3-4 years, CCSU every 5 years.
3. Record the source URL.
4. If the syllabus is a PDF, extract its text (same methods as Workflow 01, Step 2).

### Step 4: Handle Syllabus Not Found

If no syllabus is found after all search queries:

1. **Try alternative search strategies:**
   - Search for the subject name (not code) + "syllabus" + "B.Tech" or the relevant course.
   - Search for related university names (e.g., if AKTU is not found, try "UPTU" — the old name).
   - Search academic resource sites that compile syllabi.

2. **Try affiliated/comparable universities:**
   - If the university is affiliated to a larger body, search the parent body's syllabus.
   - If the university follows AICTE model curriculum, search `aicte-india.org` for the model syllabus.

3. **Infer from the paper itself:**
   - If still no syllabus found, build an approximate syllabus from the question paper topics.
   - Group questions by topic to create pseudo-units.
   - Set `verification_status` to `"inferred"`.
   - Add a prominent warning: "Syllabus was inferred from question paper analysis. It may not match the official syllabus."

4. **Ask the user:**
   - "I couldn't find the official syllabus for {subject} at {university}. Do you have a copy you can upload? Or should I work from the question paper topics?"

5. **Never fabricate a syllabus.** If you can't find it, say so. Working with an inferred syllabus is better than inventing one.

### Step 5: Parse Syllabus into Structured Format

Extract the following from the syllabus document:

#### 5A — Units

For each unit, extract:
- `unit_number`: Sequential number (1, 2, 3, ...).
- `unit_title`: The unit heading (e.g., "Introduction to Algorithms").
- `topics`: List of every topic and sub-topic mentioned under this unit.
- `hours_allocated`: Teaching hours if specified (e.g., "8 hours").

**Parsing rules:**
- Treat "Module" as equivalent to "Unit".
- If topics are numbered (1.1, 1.2, 1.3), preserve the numbering.
- If topics are listed as a comma-separated paragraph, split them into individual items.
- Include sub-topics — "Trees: Binary trees, BST, AVL trees, B-trees" should become `["Binary trees", "BST", "AVL trees", "B-trees"]` under a topic heading of "Trees".
- If a topic says "briefly" or "introduction only", note this — it means the examiner expects less depth.

#### 5B — Books

Extract two separate lists:

**Prescribed books** (textbooks that students are expected to study):
```json
{
  "title": "Introduction to Algorithms",
  "author": "Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein",
  "publisher": "MIT Press",
  "edition": "3rd"
}
```

**Reference books** (supplementary reading):
- Same structure as prescribed books.
- These are "nice to have" — students aren't expected to read them cover to cover.

**Book extraction rules:**
- Distinguish between "Text Books" / "Prescribed Books" and "Reference Books" / "Suggested Readings".
- If the syllabus just says "Books" without distinguishing, put them all in `prescribed_books`.
- Normalize author names: "Cormen et al." → full author list if known from your training data.

### Step 6: Handle Syllabus Changes Between Years

Universities revise syllabi periodically. Handle this:

1. If you found multiple syllabi for different years:
   - Identify which one was active during the exam year.
   - Record BOTH the current syllabus and the exam-year syllabus.
   - Set `is_current` to `true` for the latest one and `false` for older ones.
2. If the syllabus changed between the exam year and now:
   - Use the exam-year syllabus for question mapping (Step 7).
   - Note any new topics added in the current syllabus — they may appear in future exams.
   - Note any removed topics — they're unlikely to appear again.
3. If you can't determine which syllabus version applies:
   - Use the one that best matches the questions in the paper.
   - Log the ambiguity.

### Step 7: Map Questions to Syllabus Units

For every question extracted in Workflow 01:

1. Read the question text.
2. Identify the primary topic it tests.
3. Find which syllabus unit contains that topic.
4. Record the mapping:
   ```json
   {
     "question_id": "AKTU_KCS501_2023_dec_Q1_a",
     "mapped_unit": 1,
     "mapped_topic": "Asymptotic Notations",
     "mapping_confidence": 0.95,
     "mapping_method": "keyword_match"
   }
   ```
5. **Mapping methods:**
   - `"exact_match"`: Question explicitly names a syllabus topic (highest confidence).
   - `"keyword_match"`: Question text contains keywords from a syllabus topic.
   - `"concept_match"`: Question tests a concept that falls under a syllabus topic (requires understanding).
   - `"inferred"`: Best guess based on context (lowest confidence).

6. **Handle unmapped questions:**
   - If a question doesn't match any syllabus topic, it may be from a different syllabus version, an out-of-syllabus bonus question, or a cross-unit question.
   - Record it as `"mapped_unit": null` with a note explaining why.

### Step 8: Identify Syllabus Coverage Gaps

Compare the syllabus units against the paper questions:

1. **For each unit, calculate:**
   - Number of questions from this unit.
   - Total marks from this unit.
   - Percentage of paper marks from this unit.

2. **Identify over-represented units:** Units with disproportionately many questions.
3. **Identify under-represented units:** Units with zero or few questions — these may appear in future papers.
4. **Identify completely uncovered units:** Units with no questions at all — flag these as study priorities.

Generate a coverage table:
```
Syllabus Coverage Report
━━━━━━━━━━━━━━━━━━━━━━━━
Unit 1: Introduction to Algorithms    — 15 marks (15%) — 3 questions
Unit 2: Divide and Conquer            — 20 marks (20%) — 2 questions
Unit 3: Greedy Algorithms             — 20 marks (20%) — 2 questions
Unit 4: Dynamic Programming           — 25 marks (25%) — 3 questions
Unit 5: Graph Algorithms              — 10 marks (10%) — 1 question
Unit X: Backtracking                  — 0 marks (0%)  — ⚠️ NOT COVERED

Overall: 90% of syllabus units covered by this paper.
```

### Step 9: Assemble Syllabus JSON

Build the final JSON object conforming to `syllabus.schema.json`:

```json
{
  "syllabus_id": "AKTU_KCS501_2023",
  "university": "Dr. A.P.J. Abdul Kalam Technical University",
  "course": "B.Tech Computer Science and Engineering",
  "semester": 5,
  "subject": "Design and Analysis of Algorithms",
  "subject_code": "KCS-501",
  "applicable_year": "2023-24",
  "units": [
    {
      "unit_number": 1,
      "unit_title": "Introduction",
      "topics": ["Algorithm definition", "Asymptotic Notations", "..."],
      "hours_allocated": 8
    }
  ],
  "prescribed_books": [ ... ],
  "reference_books": [ ... ],
  "source_url": "https://aktu.ac.in/...",
  "verification_status": "verified",
  "is_current": true,
  "last_updated": "2024-01-15T10:30:00Z"
}
```

Validate against the schema. Check:
- All required fields are present (`syllabus_id`, `university`, `subject`, `units`).
- Each unit has `unit_number`, `unit_title`, and at least one topic.
- Book entries have `title` and `author`.

### Step 10: Present Results to User

Show the user:
1. The syllabus source and verification status.
2. The unit-wise topic breakdown (formatted as a readable list).
3. The question-to-unit mapping summary.
4. The coverage report.
5. Any issues or warnings.

---

## Fallback Procedures When Internet is Unavailable

1. **If the user provided a syllabus:** Use it directly — no internet needed.
2. **If no syllabus is available at all:**
   - Infer the syllabus from the question paper topics.
   - Use your training knowledge to fill in standard syllabus structures for common subjects.
   - Set `verification_status` to `"inferred"`.
   - Clearly warn: "This syllabus was reconstructed from the paper and general knowledge. It has not been verified against the official syllabus."
3. **Skip the coverage gap analysis** — it's unreliable with an inferred syllabus.
4. **Proceed to the next workflow** — an approximate syllabus is better than none.

---

## Validation Checklist

- [ ] **Syllabus source recorded** — URL, user-provided, or "inferred".
- [ ] **Verification status set** — "verified", "unverified", or "inferred".
- [ ] **All units extracted** — At least 3-5 units for a typical semester subject.
- [ ] **Topics listed per unit** — At least 3 topics per unit (typical subjects have 5-10).
- [ ] **Books extracted** — Prescribed and reference books separated.
- [ ] **Year applicability checked** — Syllabus year matches exam year.
- [ ] **Question-to-unit mapping complete** — Every question has a mapping (or is explicitly unmapped).
- [ ] **Coverage report generated** — Shows unit-wise marks distribution.
- [ ] **JSON validates against schema** — `syllabus.schema.json`.
- [ ] **Results shown to user** — User has had a chance to review and correct.

---

## Error Handling

| Error | Cause | Fallback |
|-------|-------|----------|
| University website is down | Server issues | Try cached versions (Google Cache, Wayback Machine); try alternative search |
| Syllabus PDF is corrupted | Download issue | Try re-downloading; search for alternate copies |
| Syllabus is in a regional language | Non-English university | Translate if possible; ask user for English version |
| Multiple syllabi found, unclear which applies | Syllabus revision | Compare with question topics to pick the best match |
| Subject code not found in syllabus | Autonomous college, code changed | Search by subject name instead |
| Syllabus has no unit structure | Unusual format | Create units from topic groupings |
| Some questions don't map to any syllabus unit | Out-of-syllabus question, cross-unit | Record as unmapped; note in report |

---

## Completion Criteria

This workflow is **COMPLETE** when:

1. A valid `syllabus.schema.json` object exists.
2. Every question has been mapped (or explicitly marked unmapped) to a syllabus unit.
3. The coverage report has been generated.
4. The user has been shown the results.
5. All validation checklist items pass.

**Pass this output to:** `04-previous-paper-research.md` (if the active mode uses it) or `06-deep-topic-research.md`.
