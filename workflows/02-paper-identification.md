# Workflow 02 — Paper Identification

## Title
**Identify the Complete Academic Identity of the Extracted Paper**

## Objective
Take the metadata extracted in Workflow 01 and verify, correct, or complete every field — university name, course, subject, semester, exam year, session, exam type, and examination authority. The goal is to build a fully verified academic identity for the paper so that subsequent workflows (syllabus lookup, PYQ search) can target the right institution, course, and year.

## Used By Modes
ALL modes.

---

## Required Inputs

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| Paper metadata JSON | object | YES | Output from Workflow 01 (`paper.schema.json` object) |
| Questions array | JSON array | YES | Output from Workflow 01 (`question.schema.json` array) |
| Internet access | boolean | Preferred | Web search capability — workflow degrades gracefully without it |

## Expected Outputs

| Output | Format | Description |
|--------|--------|-------------|
| Verified paper metadata | JSON (updated `paper.schema.json`) | Paper metadata with all fields verified, corrected, or filled |
| Identification report | Structured text | Confidence levels for each field, sources consulted, issues found |
| University profile | JSON object | Standard name, abbreviation, website, type, affiliation details |

---

## Step-by-Step Instructions

### Step 1: Review Extracted Metadata

1. Load the paper metadata JSON from Workflow 01.
2. Create an identification tracker — a table of every metadata field with columns: `Field`, `Extracted Value`, `Verified Value`, `Confidence`, `Source`, `Notes`.
3. Initialize all fields:

| Field | Extracted Value | Verified Value | Confidence | Source | Notes |
|-------|----------------|---------------|------------|--------|-------|
| university | _from JSON_ | _pending_ | _pending_ | — | — |
| course | _from JSON_ | _pending_ | _pending_ | — | — |
| semester | _from JSON_ | _pending_ | _pending_ | — | — |
| subject | _from JSON_ | _pending_ | _pending_ | — | — |
| subject_code | _from JSON_ | _pending_ | _pending_ | — | — |
| exam_year | _from JSON_ | _pending_ | _pending_ | — | — |
| exam_session | _from JSON_ | _pending_ | _pending_ | — | — |
| max_marks | _from JSON_ | _pending_ | _pending_ | — | — |
| exam_type | _not in JSON_ | _pending_ | _pending_ | — | regular/supplementary/model |
| exam_authority | _not in JSON_ | _pending_ | _pending_ | — | board/university conducting the exam |

### Step 2: Resolve University Identity

1. Take the extracted `university` value.
2. Check it against the **Common University Abbreviation Map** (see Appendix A below).
3. If a match is found, record the full official name and abbreviation.
4. If internet is available:
   - Search for the university name + "official website".
   - Verify the official name from the university's website.
   - Record the official URL (the `.ac.in`, `.edu`, or `.edu.in` domain).
5. Build a university profile object:
   ```json
   {
     "full_name": "Dr. A.P.J. Abdul Kalam Technical University",
     "abbreviation": "AKTU",
     "previous_names": ["UPTU", "GBTU"],
     "official_website": "https://aktu.ac.in",
     "type": "state_technical",
     "state": "Uttar Pradesh",
     "affiliation": "Government of Uttar Pradesh",
     "exam_cell_url": "https://aktu.ac.in/examinations.html"
   }
   ```
6. Set confidence:
   - `1.0` — Exact match confirmed on official website.
   - `0.9` — Matched abbreviation map but no web verification.
   - `0.7` — Partial match; some details inferred.
   - `0.5` — Ambiguous; multiple universities could match.
   - `0.3` — Guessed from context; low certainty.

### Step 3: Verify Course and Subject

1. Take the extracted `course` and `subject` values.
2. If the university profile was resolved (Step 2):
   - Search the university website for the course name (e.g., "B.Tech Computer Science Engineering").
   - Verify the subject code format matches the university's known pattern:
     - AKTU: Alphanumeric like `KCS-501`, `KOE-064`
     - CCSU: Format like `BTECH-CSE-501`
     - RGPV: Format like `CS-501`
   - If the subject code is found on the university's syllabus page, record `confidence: 1.0`.
3. Normalize course names:
   - "B.Tech CSE" → "B.Tech Computer Science and Engineering"
   - "B.Tech IT" → "B.Tech Information Technology"
   - "MCA" → "Master of Computer Applications"
   - "BCA" → "Bachelor of Computer Applications"
   - "B.Sc CS" → "B.Sc Computer Science"
4. If the subject code exists but the subject name is missing, search for the code on the university's syllabus directory.

### Step 4: Determine Exam Year and Session

1. Verify the `exam_year`:
   - Must be a reasonable year (not in the future, not before the university was established).
   - If two years are present (e.g., "2023-24"), determine which year the exam was actually held in. Usually the second year for odd-semester exams held in Dec-Jan, and the first year for even-semester exams held in May-Jun.
2. Determine the `exam_session`:
   - Map textual clues to the enum values in `paper.schema.json`:
     - "December 2023", "Dec '23" → `"dec"`
     - "May/June 2024" → `"may"` or `"jun"`
     - "Odd Semester" → `"odd"`
     - "Even Semester" → `"even"`
     - "Supplementary", "Back Paper", "Carry Over" → `"supplementary"`
     - "Special Exam" → `"special"`
   - If no session indicator is found, infer from the semester number:
     - Odd semesters (1, 3, 5, 7) are usually held in Nov-Dec → `"odd"`
     - Even semesters (2, 4, 6, 8) are usually held in May-Jun → `"even"`
   - If inference is not possible, set to `"unknown"`.

### Step 5: Classify Exam Type

Determine whether this is a regular exam, supplementary exam, or model/sample paper.

1. Look for keywords in the paper header and instructions:
   - **Regular**: "End Semester Examination", "University Examination", "Annual Examination" → `exam_type: "regular"`
   - **Supplementary**: "Supplementary", "Back Paper", "Carry Over", "Re-appear" → `exam_type: "supplementary"`
   - **Model/Sample**: "Model Question Paper", "Sample Paper", "Practice Paper" → `exam_type: "model"`
   - **Internal/Sessional**: "Sessional", "Internal Assessment", "Class Test" → `exam_type: "internal"`
2. If no keywords are found, default to `"regular"` with a note.
3. This field is important because supplementary papers sometimes have a different pattern or reduced syllabus.

### Step 6: Identify the Examination Authority

1. Determine who actually sets and conducts the exam:
   - **University-conducted**: The university itself sets the paper (most common for state universities like AKTU, RGPV, MDU).
   - **Autonomous college**: The college sets its own papers under university guidelines.
   - **Board-conducted**: An examination board (e.g., BTE for polytechnics) conducts the exam.
   - **National body**: AICTE or UGC-conducted exams (rare for regular semesters).
2. Record the authority in the identification report.
3. This matters for PYQ search — papers from autonomous colleges won't match other colleges under the same university.

### Step 7: Cross-Reference with Question Content

Use the questions themselves to verify or correct identification:

1. **Subject verification from questions:** Read through the extracted questions. Do they match the identified subject?
   - If the paper says "Data Structures" but the questions are about databases, the subject identification is wrong. Correct it.
2. **Semester verification from difficulty:** Are the questions appropriate for the identified semester?
   - Semester 1-2 questions should be introductory.
   - Semester 5-7 questions should be advanced/specialized.
3. **Marks scheme verification:** Does the marks distribution match the university's known pattern?
   - AKTU pattern: Section A (2 marks × 10), Section B (10 marks × 5 with internal choice), Section C (varies).
   - CCSU pattern: Section A (short), Section B (medium), Section C (long).
4. If cross-referencing reveals inconsistencies, update the metadata and log the correction.

### Step 8: Handle Ambiguous or Incomplete Identification

For any field where confidence is below `0.7`:

1. **Ask the user directly:** "I couldn't confidently identify the [field]. The paper seems to be from [best guess]. Can you confirm?"
2. Present what you DO know and what you're unsure about.
3. Provide multiple options when possible: "Is this paper from (a) AKTU, (b) CCSU, or (c) another university?"
4. Never proceed with a critical wrong identification — it cascades errors through all workflows.
5. If the user cannot help, proceed with the best guess but flag the uncertainty prominently in all downstream outputs.

### Step 9: Update Paper Metadata

1. Update the paper metadata JSON with all verified values.
2. Regenerate `paper_id` if the university, subject code, year, or session changed.
3. If `paper_id` changed, update all `question.paper_id` references to match.
4. Add identification metadata (not part of schema, stored separately):
   ```json
   {
     "identification": {
       "university_profile": { ... },
       "exam_type": "regular",
       "exam_authority": "university_conducted",
       "field_confidence": {
         "university": 1.0,
         "course": 0.9,
         "semester": 1.0,
         "subject": 1.0,
         "subject_code": 1.0,
         "exam_year": 1.0,
         "exam_session": 0.9
       },
       "verification_sources": ["aktu.ac.in", "abbreviation_map"],
       "identified_at": "2024-01-15T10:30:00Z"
     }
   }
   ```

### Step 10: Generate Identification Report

Produce a human-readable report:

```
🎓 Paper Identification Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
University:     Dr. A.P.J. Abdul Kalam Technical University (AKTU)  ✅ Verified
Course:         B.Tech Computer Science and Engineering              ✅ Verified
Semester:       5th                                                  ✅ Confirmed
Subject:        Design and Analysis of Algorithms                    ✅ Verified
Subject Code:   KCS-501                                              ✅ Verified
Exam Year:      2023                                                 ✅ Confirmed
Exam Session:   December (Odd Semester)                              ✅ Confirmed
Exam Type:      Regular End-Semester                                 ⚠️ Inferred
Max Marks:      100                                                  ✅ Confirmed
Duration:       3 Hours                                              ✅ Confirmed

Exam Authority: University-conducted
Overall Confidence: 96%
```

---

## Appendix A: Common University Abbreviation Map

| Abbreviation | Full Name | State | Website |
|-------------|-----------|-------|---------|
| AKTU | Dr. A.P.J. Abdul Kalam Technical University | UP | aktu.ac.in |
| UPTU | (Old name for AKTU) | UP | aktu.ac.in |
| GBTU | (Old name for AKTU) | UP | aktu.ac.in |
| CCSU | Chaudhary Charan Singh University | UP | ccsuniversity.ac.in |
| MGKVP | Mahatma Gandhi Kashi Vidyapith | UP | mgkvp.ac.in |
| RGPV | Rajiv Gandhi Proudyogiki Vishwavidyalaya | MP | rgpv.ac.in |
| MDU | Maharshi Dayanand University | Haryana | mdu.ac.in |
| KUK | Kurukshetra University | Haryana | kuk.ac.in |
| GTU | Gujarat Technological University | Gujarat | gtu.ac.in |
| VTU | Visvesvaraya Technological University | Karnataka | vtu.ac.in |
| JNTU | Jawaharlal Nehru Technological University | Telangana | jntuh.ac.in |
| MAKAUT | Maulana Abul Kalam Azad University of Technology | WB | makautexam.net |
| BPUT | Biju Patnaik University of Technology | Odisha | bput.ac.in |
| RTU | Rajasthan Technical University | Rajasthan | rtu.ac.in |
| PTU | IK Gujral Punjab Technical University | Punjab | ptu.ac.in |
| SPPU | Savitribai Phule Pune University | Maharashtra | unipune.ac.in |
| MU | University of Mumbai | Maharashtra | mu.ac.in |
| Anna | Anna University | Tamil Nadu | annauniv.edu |
| Calicut | University of Calicut | Kerala | uoc.ac.in |
| BU | Bundelkhand University | UP | bujhansi.ac.in |
| CSJMU | Chhatrapati Shahu Ji Maharaj University | UP | csjmu.ac.in |
| DBRAU | Dr. Bhimrao Ambedkar University | UP | dbrau.ac.in |
| MJPRU | Mahatma Jyotiba Phule Rohilkhand University | UP | mjpru.ac.in |
| LU | University of Lucknow | UP | lkouniv.ac.in |

> **Note:** This map is not exhaustive. When an abbreviation is not found here, search the web. Indian state technical universities frequently rename — always check for previous names.

---

## Fallback Procedures When Internet is Unavailable

If internet access is not available:

1. **Rely on the abbreviation map** (Appendix A) for university identification.
2. **Rely on subject code patterns** to infer the university:
   - Codes starting with "K" (KCS, KAS, KEE) → likely AKTU.
   - Codes starting with "RCS" or "NCS" → likely AKTU (older pattern).
   - Two-letter department prefix + 3-digit number → common state university pattern.
3. **Rely on the extracted metadata** as-is — accept whatever was printed on the paper.
4. **Set lower confidence scores** (cap at 0.7 for any unverified field).
5. **Add a disclaimer** to the identification report: "Identification performed without internet verification. Accuracy may be reduced."
6. **Proceed anyway** — do not block the entire pipeline because identification can't be verified online. Partial identification is better than no identification.

---

## Validation Checklist

- [ ] **University identified** — Full name and abbreviation set, or explicitly marked unknown.
- [ ] **Course normalized** — Full course name recorded (not just abbreviation).
- [ ] **Subject verified** — Subject name matches the actual question content.
- [ ] **Subject code format valid** — Matches the university's known code pattern (if known).
- [ ] **Exam year is reasonable** — Not in the future, not impossibly old.
- [ ] **Exam session determined** — Set to a valid enum value.
- [ ] **Exam type classified** — Regular, supplementary, model, or internal.
- [ ] **Confidence scores assigned** — Every field has a confidence between 0 and 1.
- [ ] **Paper ID updated** — Regenerated if any identifying field changed.
- [ ] **Question paper_id references updated** — All questions point to the correct paper_id.
- [ ] **User consulted for ambiguities** — Low-confidence fields were confirmed with the user.
- [ ] **Identification report generated** — Summary shown to the user.

---

## Error Handling

| Error | Cause | Fallback |
|-------|-------|----------|
| University not in abbreviation map | Uncommon or new university | Search web; if offline, use the name as-is |
| Subject code doesn't match any known pattern | Autonomous college with custom codes | Accept the code; note it may be college-specific |
| Year seems wrong (future date, pre-1950) | OCR misread, typo on paper | Ask user; check if digits were transposed |
| Conflicting metadata (e.g., semester says 5 but subject is a 3rd-sem subject) | Paper error or extraction error | Flag the conflict; ask user; proceed with the more reliable signal |
| Multiple universities share the same abbreviation | "MU" could be Mumbai or Madras | Use subject code pattern and state/region clues to disambiguate |
| Paper is from an autonomous college | Questions don't match university-common papers | Note the autonomy; adjust PYQ search strategy |

---

## Completion Criteria

This workflow is **COMPLETE** when:

1. Every metadata field has a verified value or is explicitly set to null/unknown with a reason.
2. Every field has a confidence score.
3. The university profile object is populated.
4. The identification report has been generated and shown to the user.
5. The paper_id and all question references are consistent.

**Pass this output to:** `03-syllabus-research.md` or `05-question-analysis.md` (depending on the active mode).
