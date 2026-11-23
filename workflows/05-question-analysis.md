# Workflow 05 — Question Analysis

## Title
**Analyze Question Patterns, Frequency, and Importance**

## Objective
Cross-reference the current paper's questions with the historical question database (from Workflow 04) and the syllabus (from Workflow 03). Calculate repetition frequency, classify question types, map questions to syllabus units, assign importance levels, and produce a structured pattern analysis report. This analysis powers answer prioritization, revision sheet generation, and question bank creation.

## Used By Modes
Full Research (1), Paper Solution (2), Previous Year Analysis (4), Question Bank (6).

---

## Required Inputs

| Input | Type | Required | Description |
|-------|------|----------|-------------|
| Current paper questions | JSON array | YES | From Workflow 01 |
| Historical question database | JSON array | Preferred | From Workflow 04 (may be empty if PYQs weren't found) |
| Paper source registry | JSON array | Preferred | From Workflow 04 |
| Syllabus object | JSON | Preferred | From Workflow 03 (may not exist for some modes) |
| Verified paper metadata | JSON | YES | From Workflow 02 |

## Expected Outputs

| Output | Format | Schema | Description |
|--------|--------|--------|-------------|
| Analyzed questions array | JSON array | Extended `question.schema.json` with analysis fields | Each question enriched with frequency, type, importance |
| Topic importance matrix | JSON object | — | Topic → importance level → evidence |
| Unit-wise analysis | JSON array | — | Per-unit question count, marks, frequency stats |
| Pattern analysis report | Structured text | — | Human-readable summary of findings |
| Topic objects | JSON array | `schemas/topic.schema.json` | One object per identified topic with frequency data |

---

## Step-by-Step Instructions

### Step 1: Prepare the Data

1. Load the current paper's questions array.
2. Load the historical question database (if available).
3. Load the syllabus (if available).
4. Count available data:
   - Total PYQ papers: `N_papers`
   - Total PYQ questions: `N_pyq_questions`
   - Total current paper questions: `N_current`
   - Syllabus units: `N_units`
5. If `N_papers` is 0 (no PYQs available):
   - Log: "No historical data available. Analysis limited to current paper only."
   - Skip Steps 3-4 (frequency analysis). Proceed with Steps 5-9 (classification and mapping).
6. If `N_papers` is 1-2:
   - Log: "Limited historical data (only {N} papers). Frequency percentages may be unreliable."

### Step 2: Classify Question Types

For every question in the current paper, determine its `question_type` using these classification rules:

| Type | Identifying Signals | Examples |
|------|-------------------|----------|
| `definition` | "Define", "What is", "What do you mean by" | "Define normalization." |
| `explanation` | "Explain", "Describe", "Discuss", "Elaborate" | "Explain the working of a stack." |
| `comparison` | "Compare", "Differentiate", "Distinguish between", "vs" | "Compare TCP and UDP." |
| `numerical` | Numbers, formulas, "Calculate", "Find", "Solve", "Compute" | "Find the shortest path using Dijkstra's algorithm for the given graph." |
| `diagram` | "Draw", "Sketch", "Illustrate", "Show with diagram" | "Draw the ER diagram for a library management system." |
| `essay` | "Write an essay", "Discuss in detail", long-answer, 10+ marks | "Discuss the evolution of operating systems." |
| `short-answer` | 1-3 marks, "Write short notes", "Brief answer" | "Write a short note on deadlock." |
| `mcq` | Multiple options (a), (b), (c), (d) | "Which of the following is not a sorting algorithm? (a)..." |
| `practical` | "Write a program", "Write code", "Write an algorithm in pseudocode" | "Write a C program to implement binary search." |
| `application` | "Apply", "Using...solve", "Given...find", real-world scenario | "Apply Kruskal's algorithm to find the MST of the given graph." |

**Classification rules:**
1. If a question matches multiple types, pick the **primary** type (the one that best describes what the examiner wants).
2. If a question asks "Define and explain", classify as `explanation` (the higher-effort type dominates).
3. If a question says "Draw and explain", classify as `diagram`.
4. If unsure, classify as `explanation` (the most common default).
5. Record the classification in each question object's `question_type` field.

### Step 3: Detect Question Repetitions

Compare every question in the current paper against every question in the historical database. This is the core frequency analysis step.

#### 3A — Exact Match Detection

Two questions are an **exact match** when:
- The question text is identical or nearly identical (after normalizing whitespace, capitalization, and minor punctuation differences).
- Both ask for the same thing with the same data/values (for numerical questions).

**How to check:**
1. Normalize both question texts: lowercase, strip extra whitespace, remove trailing punctuation.
2. Compare. If similarity > 90% (by character overlap or semantic meaning), it's an exact match.
3. For numerical questions, also check if the given values are the same.

Record: `match_type: "exact"`, `matched_question_id`, `matched_paper_year`.

#### 3B — Concept Match Detection

Two questions are a **concept match** when:
- They test the same underlying concept but are worded differently.
- They ask about the same topic but with different data, examples, or angles.

**How to check:**
1. Extract the core concept/topic from each question (e.g., "Dijkstra's algorithm", "normalization", "process scheduling").
2. If two questions share the same core concept, they are concept matches.
3. Be careful: "Explain Dijkstra's algorithm" and "Apply Dijkstra's algorithm to this graph" are concept matches — they test the same topic but at different cognitive levels.

Record: `match_type: "concept"`, `matched_question_id`, `matched_paper_year`.

#### 3C — No Match

If a question has no exact or concept match in the historical database:
- It may be a new question (testing a topic not previously asked).
- Or the historical database is incomplete.
- Record: `match_type: "none"`.

### Step 4: Calculate Repetition Frequency

For each question/concept in the current paper:

1. Count how many times it appeared in the historical database:
   - `exact_repeat_count`: Number of exact matches across all PYQ papers.
   - `concept_repeat_count`: Number of concept matches across all PYQ papers.
   - `total_appearance_count`: `exact_repeat_count + concept_repeat_count`.
2. List the years it appeared: `appeared_in_years: [2022, 2021, 2020]`.
3. Calculate frequency percentage: `(total_appearance_count / N_papers) × 100`.
4. Determine the streak: Did it appear in consecutive years? A 3-year streak is highly significant.

**Example:**
```json
{
  "question_id": "AKTU_KCS501_2023_dec_Q3_a",
  "question_text": "Explain Dijkstra's algorithm with an example.",
  "frequency": {
    "exact_repeat_count": 2,
    "concept_repeat_count": 1,
    "total_appearance_count": 3,
    "appeared_in_years": [2022, 2021, 2020],
    "frequency_percentage": 75,
    "consecutive_years": 3,
    "evidence_type": "exact_match"
  }
}
```

### Step 5: Map Questions to Syllabus Units

If the syllabus is available (from Workflow 03):

1. Take the question-to-unit mapping from Workflow 03, Step 7.
2. For questions that weren't mapped in Workflow 03, attempt mapping now using the question analysis context.
3. For PYQ questions, map them to units as well (this enables unit-wise frequency analysis).
4. Record `unit` and `topic` on each question object.

If no syllabus is available:
1. Group questions by their identified topics.
2. Create ad-hoc topic groups (not formal syllabus units).
3. Note that unit-wise analysis is approximate.

### Step 6: Classify Importance Levels

Assign an importance level to each question/topic using this four-tier system:

| Level | Label | Criteria | Evidence Required |
|-------|-------|----------|-------------------|
| **A** | Historically Repeated | Appeared in 3+ papers OR appeared in 2+ consecutive years | Exact or concept matches with PYQ question IDs and years |
| **B** | Frequently Tested Concept | The underlying concept (not exact question) appears in 2+ papers | Concept match references |
| **C** | Syllabus Important | Topic is in the syllabus but has limited or no PYQ history | Syllabus unit reference |
| **D** | Conceptual Prerequisite | Topic is a building block for higher-importance topics | Prerequisite relationship to a Level A or B topic |

**Classification rules:**

1. **Start with the evidence.** Check PYQ frequency first → assign A or B if qualified.
2. If no PYQ evidence, check syllabus → assign C if the topic is in the syllabus.
3. If the topic is a prerequisite (you need to understand X before Y), assign D.
4. Never assign Level A without at least 3 appearances or a 2+ year streak.
5. Never assign Level B without at least 2 concept-level appearances.
6. If no PYQ data exists at all, assign C to all syllabus topics and skip A/B.

**Record the evidence for each classification:**
```json
{
  "topic": "Dijkstra's Algorithm",
  "importance_level": "A",
  "evidence": {
    "exact_repeats": ["PYQ_AKTU_KCS501_2022_Q3", "PYQ_AKTU_KCS501_2020_Q5"],
    "concept_repeats": ["PYQ_AKTU_KCS501_2021_Q4"],
    "total_appearances": 3,
    "consecutive_streak": "2020-2022 (3 years)",
    "classification_reason": "Appeared in 3 out of 4 papers, with 3-year consecutive streak."
  }
}
```

### Step 7: Build Topic-Importance Matrix

Create a comprehensive matrix that shows every identified topic with its analysis:

```
Topic-Importance Matrix
━━━━━━━━━━━━━━━━━━━━━━━

| # | Topic | Unit | Level | Appearances | Years | Marks Range | Type |
|---|-------|------|-------|-------------|-------|-------------|------|
| 1 | Dijkstra's Algorithm | 4 | A | 3/4 (75%) | 2020,21,22 | 5-10 | numerical/explanation |
| 2 | Knapsack Problem | 3 | A | 3/4 (75%) | 2020,21,23 | 7-10 | numerical |
| 3 | BFS/DFS | 4 | B | 2/4 (50%) | 2021,22 | 5-7 | explanation |
| 4 | Asymptotic Notations | 1 | B | 2/4 (50%) | 2020,23 | 2-5 | definition/explanation |
| 5 | Backtracking | 3 | C | 0/4 (0%) | — | — | — |
| 6 | Recurrence Relations | 1 | D | 1/4 (25%) | 2022 | 5 | numerical |
```

Sort the matrix by importance level (A first, then B, C, D), then by frequency percentage (highest first).

### Step 8: Generate Unit-Wise Analysis

For each syllabus unit (or topic group if no syllabus):

```json
{
  "unit_number": 4,
  "unit_title": "Graph Algorithms",
  "total_questions_this_paper": 3,
  "total_marks_this_paper": 22,
  "marks_percentage_this_paper": 22,
  "historical_average_questions": 2.5,
  "historical_average_marks": 18,
  "top_topics": [
    {"topic": "Dijkstra's Algorithm", "importance": "A"},
    {"topic": "BFS/DFS", "importance": "B"},
    {"topic": "MST (Prim's/Kruskal's)", "importance": "B"}
  ],
  "trend": "consistent",
  "recommendation": "High-priority unit. Graph algorithms appear in every paper."
}
```

**Trend values:**
- `"increasing"`: More questions from this unit in recent years.
- `"decreasing"`: Fewer questions from this unit in recent years.
- `"consistent"`: Roughly the same coverage across years.
- `"sporadic"`: Appears some years, absent others.
- `"new"`: Only started appearing recently.
- `"unknown"`: Not enough data to determine trend.

### Step 9: Build Topic Objects

For each identified topic, create a topic object conforming to `topic.schema.json`:

```json
{
  "topic_id": "AKTU_KCS501_dijkstra",
  "topic_name": "Dijkstra's Algorithm",
  "unit_number": 4,
  "unit_title": "Graph Algorithms",
  "syllabus_id": "AKTU_KCS501_2023",
  "subtopics": ["Single-source shortest path", "Relaxation", "Priority queue implementation"],
  "prerequisite_topics": ["AKTU_KCS501_graph_representation", "AKTU_KCS501_bfs"],
  "related_topics": ["AKTU_KCS501_bellman_ford", "AKTU_KCS501_floyd_warshall"],
  "importance_level": "critical",
  "exam_frequency": {
    "times_appeared": 3,
    "years": [2020, 2021, 2022],
    "evidence_type": "exact_match"
  }
}
```

**Mapping importance levels to `topic.schema.json` enum:**
- Level A → `"critical"`
- Level B → `"high"`
- Level C → `"medium"`
- Level D → `"low"`

### Step 10: Generate the Pattern Analysis Report

Produce a comprehensive, human-readable report:

```
📊 Question Pattern Analysis Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Paper: AKTU KCS-501 (Design and Analysis of Algorithms) — Dec 2023
Data Source: 4 previous year papers (2020-2023)
Analysis Confidence: HIGH (4+ papers available)

🔴 Level A — Historically Repeated (Study these first)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Dijkstra's Algorithm — appeared in 3/4 papers (75%)
   Years: 2020, 2021, 2022 | Marks: 5-10 | Streak: 3 consecutive years
   Evidence: Exact repeats in 2022 (Q3) and 2020 (Q5); concept repeat in 2021 (Q4)

2. Knapsack Problem (0/1 and Fractional) — appeared in 3/4 papers (75%)
   Years: 2020, 2021, 2023 | Marks: 7-10 | Type: Numerical
   Evidence: Exact repeat in 2021 (Q7); concept repeats in 2020, 2023

🟠 Level B — Frequently Tested Concepts
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3. BFS/DFS Traversal — appeared in 2/4 papers (50%)
   ...

🟡 Level C — Syllabus Important (No strong PYQ signal)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
7. Backtracking — in syllabus (Unit 3) but not found in available PYQs
   ...

🔵 Level D — Conceptual Prerequisites
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
10. Recurrence Relations — prerequisite for understanding Divide & Conquer
    ...

📈 Unit-Wise Summary
━━━━━━━━━━━━━━━━━━━━
Unit 1 (Introduction):        15 marks — consistent
Unit 2 (Divide & Conquer):    20 marks — consistent
Unit 3 (Greedy Algorithms):   20 marks — increasing
Unit 4 (Dynamic Programming): 25 marks — consistent
Unit 5 (Graph Algorithms):    20 marks — consistent
```

### Critical Integrity Rules

**These are absolute requirements. Breaking any of these invalidates the analysis.**

1. **NEVER claim a question WILL DEFINITELY appear.** No prediction is a certainty. Use language like "has appeared frequently" or "historically repeated" — never "will come" or "guaranteed."
2. **NEVER fabricate probability scores.** Don't write "80% chance of appearing" — this is not a statistical prediction. Use frequency percentage (times appeared ÷ papers analyzed × 100) and label it clearly as historical frequency, not probability.
3. **NEVER inflate importance.** If a topic appeared once in 5 papers, it's not "frequently tested." Be honest with the data.
4. **Always state the sample size.** "Appeared in 3/4 papers" tells the student how much data the analysis is based on. Don't just say "frequently asked" without the numbers.
5. **Distinguish exact repeats from concept matches.** An exact repeat is stronger evidence than a concept match. Don't treat them equally.
6. **If PYQ data is insufficient (< 3 papers), say so.** Warn the student that the analysis has limited statistical power.

---

## Validation Checklist

- [ ] **Every question classified** — All current paper questions have a `question_type`.
- [ ] **Frequency data calculated** — Every question has repeat counts and appearance years (or "no PYQ data").
- [ ] **Importance levels assigned** — Every topic has a level (A/B/C/D) with supporting evidence.
- [ ] **Topic-importance matrix built** — All topics listed with their analysis.
- [ ] **Unit-wise analysis done** — Every syllabus unit has aggregate stats.
- [ ] **Topic objects created** — Conforming to `topic.schema.json`.
- [ ] **No fabricated predictions** — No "will definitely appear" claims.
- [ ] **No fake probability scores** — Only historical frequency percentages.
- [ ] **Sample size stated** — Number of PYQ papers clearly indicated.
- [ ] **Evidence documented** — Every Level A/B classification has specific PYQ references.
- [ ] **Pattern report generated** — Comprehensive, human-readable, shown to user.

---

## Error Handling

| Error | Cause | Fallback |
|-------|-------|----------|
| No PYQ data at all | Workflow 04 found nothing | Skip frequency analysis; classify all topics as Level C based on syllabus |
| Very few PYQs (1-2 papers) | Limited availability | Run analysis but add a heavy disclaimer about reliability |
| No syllabus available | Workflow 03 skipped or failed | Group questions by topic without formal unit mapping |
| Questions don't match any PYQ | New syllabus, changed question pattern | Classify as Level C; note the pattern change |
| Conflicting frequency data | Same question counted differently | Recount manually; resolve duplicates |
| Topic appears frequently but isn't in syllabus | Syllabus changed, or out-of-syllabus bonus | Note the discrepancy; include the topic but flag it |

---

## Completion Criteria

This workflow is **COMPLETE** when:

1. Every current paper question has been classified by type.
2. Frequency analysis has been run (or explicitly skipped with reason).
3. Importance levels are assigned with evidence.
4. The topic-importance matrix is built.
5. Unit-wise analysis is done.
6. Topic objects conforming to `topic.schema.json` are created.
7. The pattern analysis report has been generated and shown to the user.
8. All integrity rules have been followed.
9. All validation checklist items pass.

**Pass this output to:** `06-deep-topic-research.md` (for modes 1, 2) or `09-question-bank-generation.md` (for mode 6) or `10-final-publishing.md` (for mode 4).
