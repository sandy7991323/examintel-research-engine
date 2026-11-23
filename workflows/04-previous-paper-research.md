# Workflow 04 — Previous Year Paper Research

## Title
**Find and Analyze Previous Year Question Papers Related to the Uploaded Paper**

## Objective
Search for previous year question papers (PYQs) from the same university, course, and subject. Extract questions from found papers, build a historical question database, and record every source with its verification status. This database feeds directly into Workflow 05 (Question Analysis) for frequency calculations and pattern detection.

## Used By Modes
Full Research (1), Previous Year Analysis (4), Question Bank (6).

---

## Required Inputs

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| Verified paper metadata | JSON | YES | From Workflow 02 |
| University profile | JSON | YES | From Workflow 02 |
| Syllabus object | JSON | Preferred | From Workflow 03 (helps with topic matching) |
| Questions array | JSON | YES | From Workflow 01 (the current paper's questions) |
| Internet access | boolean | YES | This workflow requires internet — without it, skip to fallback |

## Expected Outputs

| Output | Format | Description |
|--------|--------|-------------|
| Historical question database | JSON array | All questions extracted from found PYQs |
| Paper source registry | JSON array | Every PYQ found, with source URL, year, verification status |
| Search log | Plain text | Every search query, portal visited, what was found/not found |
| PYQ summary | Structured text | How many papers found, years covered, source quality |

---

## Step-by-Step Instructions

### Step 1: Build Search Strategy

Before searching, define exactly what you're looking for:

1. **Primary target:** Papers from the **same university + same subject code + different years**.
2. **Secondary target:** Papers from the **same university + same subject name** (code may have changed).
3. **Tertiary target:** Papers from **affiliated colleges under the same university**.
4. **Quaternary target:** Papers from **comparable universities with similar syllabus** (use only if primary/secondary yield fewer than 3 papers).

Record the search strategy. Example:
```
Search Strategy:
  University: AKTU (also search: UPTU, GBTU — old names)
  Subject Code: KCS-501 (also search: RCS-503, NCS-503 — old codes)
  Subject Name: Design and Analysis of Algorithms (also: DAA, Algorithms)
  Course: B.Tech CSE
  Target Years: 2018-2023 (5 years back from exam year)
```

### Step 2: Search University-Specific Portals

Search these portal categories in order. For each portal, record whether it was accessible, what was found, and the URLs.

#### 2A — Official University Exam Archives

1. Navigate to the university's official exam cell or results portal.
2. Look for "Previous Year Papers", "Question Bank", "Model Papers", or "Old Papers" sections.
3. Common URL patterns to try:
   - `{university_domain}/examinations`
   - `{university_domain}/question-papers`
   - `{university_domain}/old-papers`
   - `{university_domain}/archive`

#### 2B — University-Specific Community Sites

Search portals that specialize in papers from specific universities:

| University | Known Portals | URL |
|-----------|--------------|-----|
| AKTU | AKTU Online, AKTU Quantum | aktuonline.com, aktuquantum.com |
| CCSU | CCSU Study | ccsustudy.com |
| RGPV | RGPV Online, RGPV Notes | rgpvonline.com |
| GTU | GTU Papers, GTU Exam | gtupapers.com |
| VTU | VTU Solutions | vtusolution.in |
| JNTU | JNTU World, JNTU Hub | jntuworld.com |
| MDU | MDU Study, MDU Questions | mdustudy.com |
| MAKAUT | MAKAUT Buddy | makautbuddy.in |
| BPUT | BPUT Study Material | bputstudymaterial.com |
| Anna | Anna University Questions | annauniv.info |
| SPPU | SPPU Papers | — search dynamically |
| General | Stupidsid, ExamSIDE, PaperToStudy | stupidsid.com, examside.com |

**For each portal:**
1. Search for the subject code first, then subject name.
2. Record: portal name, URL visited, papers found (with years), download status.
3. If a portal requires login/payment, note it and skip — never create accounts or pay.

#### 2C — General Academic Search

Run these web searches:

1. `"{subject_code}" "{university_abbreviation}" question paper previous year`
2. `"{subject_name}" "{university_abbreviation}" question paper PDF`
3. `"{subject_code}" question paper {year-1} {year-2} {year-3}`
4. `site:*.ac.in "{subject_code}" question paper`

### Step 3: Evaluate and Record Each Found Paper

For every paper found, create a source registry entry:

```json
{
  "source_id": "PYQ_AKTU_KCS501_2022_dec",
  "university": "AKTU",
  "subject_code": "KCS-501",
  "subject_name": "Design and Analysis of Algorithms",
  "exam_year": 2022,
  "exam_session": "dec",
  "source_url": "https://aktuonline.com/papers/kcs501-2022.pdf",
  "source_portal": "AKTU Online",
  "verification_status": "verified",
  "access_method": "direct_download",
  "paper_quality": "good",
  "extraction_status": "extracted",
  "notes": ""
}
```

**Verification status values:**
- `"verified"` — Paper is from an official university source or a highly trusted portal, and the content matches the subject.
- `"likely_authentic"` — Paper is from a known community portal; content matches the subject and university pattern.
- `"unverified"` — Paper is from an unknown source; could not be verified.
- `"suspicious"` — Paper has red flags (wrong subject code, inconsistent formatting, possibly fake).

**Paper quality values:**
- `"excellent"` — Clear digital PDF, all text readable.
- `"good"` — Readable scan, minor quality issues.
- `"fair"` — Some portions hard to read but most questions extractable.
- `"poor"` — Significant readability issues.

### Step 4: Extract Questions from Found Papers

For each found paper with `extraction_status` not yet "extracted":

1. Apply the same extraction process as Workflow 01 (Steps 2-5), but in a simplified form:
   - Extract question text, marks, and question number.
   - You do NOT need full metadata extraction — you already know the university/subject/year.
   - You do NOT need to show the user an extraction summary for each PYQ.
2. Create question objects with:
   - `question_id`: Use pattern `PYQ_{university}_{code}_{year}_{session}_Q{N}_{sub}`
   - `paper_id`: Link to the source registry entry.
   - `question_text`: Full question text.
   - `marks`: Mark allocation.
   - `question_type`: Classify (definition, explanation, comparison, etc.)
3. If a paper is too poor quality to extract reliably, set `extraction_status` to `"failed"` and move on.
4. If a paper is behind a paywall or login wall, set `extraction_status` to `"inaccessible"` and move on.

### Step 5: Build the Historical Question Database

1. Combine all extracted PYQ questions into a single database array.
2. Add the current paper's questions to the same database (they're part of the historical record too).
3. Sort by year (newest first).
4. For each question, ensure these fields are populated:
   - `question_id`
   - `paper_id`
   - `exam_year`
   - `question_text`
   - `marks`
   - `question_type`
   - `topic` (map to syllabus unit if syllabus is available from Workflow 03)
5. Count the total:
   - Total PYQ papers found.
   - Total questions extracted across all papers.
   - Year range covered (e.g., "2019-2023, 5 papers").

### Step 6: Search for Comparable University Papers (If Needed)

Only execute this step if fewer than 3 papers were found in Steps 2-4.

1. Identify universities with a comparable syllabus for this subject. Use the syllabus from Workflow 03 to judge similarity.
2. Search for papers from those universities.
3. **Clearly label these as "comparable" — not same university.** They are useful for understanding question patterns but should NOT be mixed with same-university frequency data.
4. Store them in a separate section of the database with a flag: `"is_comparable": true`.

### Step 7: Honesty and Integrity Rules

**These rules are non-negotiable:**

1. **Never invent paper references.** If you didn't find a paper, don't claim it exists.
2. **Never fabricate questions.** Every question in the database must come from an actual paper you found and extracted.
3. **Never invent source URLs.** Every URL in the source registry must be a real URL you visited.
4. **Never claim a portal had a paper if you didn't actually find it there.**
5. **Be transparent about search coverage:**
   - "I found papers for 2021, 2022, and 2023. I could not find papers for 2019 or 2020."
   - "The 2021 paper was from an unverified source. Use its data with caution."
6. **Distinguish between exact question repeats and similar-topic questions:**
   - Exact repeat: The question text is nearly identical (word-for-word or minor rewording).
   - Similar topic: Different question, but tests the same concept.
   - Don't conflate these two categories.

### Step 8: Handle Search Failures Gracefully

| Scenario | Action |
|----------|--------|
| No PYQs found at all | Report honestly. Suggest the user check with seniors or their college library. Proceed with single-paper analysis only. |
| Only 1-2 papers found | Report the limited data. Warn that frequency analysis will be unreliable. Proceed anyway. |
| Papers found but can't be extracted (image quality) | Record the source for the user's reference. Mark as `"extraction_status": "failed"`. |
| Papers found but behind paywall | Record the source URL. Mark as `"extraction_status": "inaccessible"`. Inform the user where to find them. |
| Portal is down or unreachable | Record the portal and the error. Try again with alternative portals. |
| Papers found are from wrong subject | Do NOT include them. Log the false match. |

### Step 9: Generate PYQ Summary Report

```
📚 Previous Year Paper Research Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
University:  AKTU
Subject:     Design and Analysis of Algorithms (KCS-501)

Papers Found: 4 (out of 5 years searched)
Year Range:   2020 — 2023

| Year | Session | Source | Quality | Status |
|------|---------|--------|---------|--------|
| 2023 | Dec     | Current paper | — | Extracted ✅ |
| 2022 | Dec     | aktuonline.com | Good | Extracted ✅ |
| 2021 | Dec     | aktuonline.com | Fair | Extracted ✅ |
| 2020 | Feb     | Official AKTU | Good | Extracted ✅ |
| 2019 | Dec     | — | — | ❌ Not Found |

Total Questions Extracted: 87 (across 4 papers)
Comparable University Papers: 0

⚠️  Notes:
  - 2019 paper could not be found on any portal.
  - 2021 paper has 2 questions with partially unreadable text.

Search Portals Checked: 4
  ✅ aktuonline.com — 2 papers found
  ✅ aktu.ac.in — 1 paper found
  ❌ aktuquantum.com — no papers for this subject
  ❌ stupidsid.com — portal returned no results
```

---

## Fallback Procedures When Internet is Unavailable

If internet access is not available:

1. **Check if the user has uploaded any other papers.** If so, use those.
2. **Report clearly:** "I cannot search for previous year papers without internet access. PYQ frequency analysis will be skipped."
3. **Skip this workflow entirely.** Set the PYQ database to empty.
4. **In downstream workflows, disable frequency-based claims.** Without PYQ data, never state "this question is frequently asked" — there's no evidence.
5. **Proceed with single-paper analysis** using only the current paper.

---

## Validation Checklist

- [ ] **Search strategy documented** — University, codes, names, year range all recorded.
- [ ] **At least 3 portals searched** — Or all relevant portals attempted.
- [ ] **Source registry complete** — Every found paper has a registry entry with URL and verification status.
- [ ] **Questions extracted from found papers** — Or extraction failure documented.
- [ ] **Historical database built** — All questions from all found papers in one array.
- [ ] **No fabricated data** — Every question and source is real and traceable.
- [ ] **Comparable papers separated** — Clearly flagged if from other universities.
- [ ] **Search failures documented** — Missing years, inaccessible portals, etc.
- [ ] **Summary report generated** — Shows what was found, what wasn't, and from where.
- [ ] **User informed** — Summary shared with the user.

---

## Error Handling

| Error | Cause | Fallback |
|-------|-------|----------|
| Search returns irrelevant results | Generic subject name, common university | Narrow search with subject code + university name |
| Portal has CAPTCHA or anti-bot | Automated access blocked | Skip the portal; note it in the log; try alternatives |
| Downloaded PDF is corrupted | Incomplete download | Try re-downloading; if fails, mark as "failed" |
| Paper is in a different language | Regional university | Extract if possible; note the language barrier |
| Wrong subject papers appear | Similar subject codes | Verify by reading questions; discard mismatches |
| Rate limiting from search engine | Too many queries | Space queries; prioritize the most specific ones |

---

## Completion Criteria

This workflow is **COMPLETE** when:

1. A systematic search has been performed (all relevant portals attempted).
2. The source registry is populated for every paper found (or attempted).
3. Questions have been extracted from all accessible papers.
4. The historical question database is assembled.
5. The PYQ summary report has been generated and shown to the user.
6. All honesty rules have been followed — no fabricated data.
7. All validation checklist items pass.

**Pass this output to:** `05-question-analysis.md`
