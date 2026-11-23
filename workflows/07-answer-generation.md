# Workflow 07 — Answer Generation

## Title

Examination-Ready Answer Generation

## Objective

Generate mark-calibrated, examination-ready model answers for every question
extracted from the paper. Each answer must read like it was written by an
experienced teacher, follow the mark-wise length rules, and pass the human
writing checklist.

---

## Required Inputs

| Input | Source | Required? |
|-------|--------|-----------|
| Extracted questions | `workflows/01-paper-extraction.md` output | Yes |
| Question analysis | `workflows/05-question-analysis.md` output | Yes |
| Topic research data | `workflows/06-deep-topic-research.md` output | Yes |
| Answer length rules | `config/answer-length-rules.yaml` | Yes |
| Language rules | `config/language-rules.yaml` | Yes |
| Source registry | `workflows/06-deep-topic-research.md` output | Yes |

---

## Step-by-Step Instructions

### Step 1 — Prepare the Answer Queue

1. List every question from the extraction output.
2. For each question, pull from the analysis data:
   - `marks` allocated
   - `question_type` (definition, explanation, comparison, numerical, etc.)
   - `topic` and `unit`
   - `special_instructions` (word limit, "draw diagram," etc.)
3. Sort by question number to maintain paper order.
4. If the paper has internal choices (OR questions), generate answers for
   **all** choices — the student needs every option covered.

### Step 2 — Determine Depth per Question

Look up the marks in `config/answer-length-rules.yaml` and set:

| Marks | Target Words | Structure | Key Elements |
|-------|-------------|-----------|-------------|
| 1 | 15–40 | Direct definition | Definition or single fact |
| 2 | 40–80 | Brief paragraph | Definition + one example |
| 3 | 80–150 | Structured short | Definition + 2–3 points + example |
| 4 | 120–200 | Structured short | Concept + 3–4 points + diagram |
| 5 | 200–350 | Medium essay | Intro → explanation → diagram → closing |
| 7–8 | 400–600 | Sectioned essay | Intro → theory → diagram → example → advantages → summary |
| 10 | 500–800 | Full essay | Intro → definition → explanation → diagrams → examples → comparison → conclusion |
| 15 | 800–1200 | Comprehensive | All of 10 + case study + analysis + multiple diagrams |
| 20 | 1200–1800 | Exhaustive | All of 15 + derivations + extended discussion |

**Override rule:** If the paper specifies a word limit or format for a question,
follow the paper's instructions — they outrank everything in this table.

### Step 3 — Select Answer Structure by Question Type

#### Type: DEFINE

```
Structure:
  → Direct definition (1–2 sentences)
  → Key characteristic that distinguishes this from similar concepts
  → One concrete example
  → (If 3+ marks) Brief expansion on why it matters
```

#### Type: EXPLAIN

```
Structure:
  → Opening sentence that states what this is
  → How it works (step by step if it's a process)
  → Why it's done this way (the reasoning)
  → Concrete example the student can picture
  → (If 5+ marks) Diagram showing the mechanism
  → Brief wrap-up connecting back to the main point
```

#### Type: COMPARE (Differentiate / Distinguish)

```
Structure:
  → One-line intro: what both items are and why comparing them matters
  → Comparison table with 5–8 aspects (adjust to marks)
  → 1–2 sentences highlighting the most important difference
  → When to use each one (practical guidance)
```

#### Type: ADVANTAGES / DISADVANTAGES (Discuss)

```
Structure:
  → Brief definition of the concept (2–3 sentences)
  → Advantages (numbered list, each with a one-line explanation)
  → Disadvantages (same format)
  → (If 7+ marks) Real-world scenario showing trade-offs
  → Closing: overall assessment — when is this approach worthwhile?
```

#### Type: NUMERICAL / CALCULATION

```
Structure:
  → Given: list all known values with units
  → Required: state what needs to be found
  → Formula: write the formula with variable definitions
  → Explanation: one line on why this formula applies
  → Substitution: plug in the values
  → Step-by-step calculation: show every intermediate step
  → Answer: final result with correct units, boxed or highlighted
  → Verification: quick sanity check (units match? magnitude reasonable?)
```

#### Type: PROGRAMMING / CODE

```
Structure:
  → Problem statement (restated clearly)
  → Concept: which algorithm or technique applies and why
  → Algorithm: step-by-step logic in plain English
  → Code: clean, commented, working code
  → Sample Output: expected result for a sample input
  → Explanation: walk through key lines of code
  → Common Errors: 2–3 mistakes students make with this code
```

#### Type: DIAGRAM-BASED

```
Structure:
  → Brief intro (what the diagram shows and why it matters)
  → Diagram: Mermaid/SVG with clear labels and caption
  → Explanation: walk through each part of the diagram
  → How the parts connect and interact
  → (If 7+ marks) Variations or special cases
```

### Step 4 — Write Each Answer

For every question, write the answer following these rules:

#### Writing Style Rules (Complete Inline Reference)

**Voice and tone:**
- Write like an experienced teacher explaining to a student face-to-face.
- Use simple vocabulary: "use" not "utilize," "start" not "commence."
- Active voice by default: "The CPU fetches the instruction."
- Contractions are fine: "don't," "isn't," "can't" — use naturally.
- Address the reader directly when it helps: "you," "your."

**Sentence and paragraph flow:**
- Vary sentence length. Short sentences for impact. Longer ones for reasoning.
- Never start three consecutive paragraphs the same way.
- Transitions should be invisible — if you need "Furthermore," restructure.
- Each paragraph: 3–5 sentences. No single-sentence paragraphs except for emphasis.

**Content approach:**
- Explain WHY, not just WHAT. Don't state facts — give the reasoning behind them.
- Use real, concrete examples a student can picture. Not "for instance, consider a scenario" — give the actual scenario.
- Never repeat the question back in different words as the first line.
- Short answers: direct definition → key points → done. No fluff.
- Medium answers: intro → explanation → example → brief closing line.
- Long answers: intro → definition → detailed explanation → types/components → examples → diagrams → applications → conclusion.

**The Top 20 Banned AI Clichés — Never Use These:**

| # | Banned Phrase | Use Instead |
|---|--------------|-------------|
| 1 | "delve into" | "look at" or "examine" |
| 2 | "it is important to note" | just state the fact |
| 3 | "in today's modern world" | "today" or "now" |
| 4 | "comprehensive overview" | "summary" or "overview" |
| 5 | "plays a crucial role" | "matters because" or "is key to" |
| 6 | "leverage" | "use" |
| 7 | "utilize" | "use" |
| 8 | "in the realm of" | "in" |
| 9 | "it should be noted" | "keep in mind" or drop it |
| 10 | "furthermore" / "moreover" | "also" or restructure |
| 11 | "a myriad of" | "many" |
| 12 | "in conclusion" | "to sum up" or just conclude |
| 13 | "embark on a journey" | "start" or "begin" |
| 14 | "serves as a cornerstone" | "is the foundation of" |
| 15 | "multifaceted" | "complex" or "has several parts" |
| 16 | "holistic approach" | "complete approach" |
| 17 | "paradigm shift" | "major change" |
| 18 | "cutting-edge" | "latest" or "modern" |
| 19 | "robust" | "strong" or "reliable" |
| 20 | "seamless" | "smooth" |

### Step 5 — Add Diagrams and Tables Where They Add Value

- Include a diagram when it genuinely helps understanding — not as decoration.
- Use Mermaid syntax for flowcharts, sequence diagrams, and state diagrams.
- Use Markdown tables for comparisons and tabular data.
- Every diagram gets: a figure number, a clear caption, and labeled parts.
- Every table gets: a header row, consistent alignment, and a caption.
- If image generation tools aren't available, use Mermaid code blocks or
  well-structured ASCII art.

### Step 6 — Review Against Human Writing Checklist

Before finalizing each answer, verify:

- [ ] Does it sound like a teacher wrote it, not a chatbot?
- [ ] Are there any banned phrases from the cliché list?
- [ ] Is the first sentence a direct start (not a restatement of the question)?
- [ ] Does the word count fall within the mark-wise range?
- [ ] Are sentences varied in length (not all 15 words, not all 30)?
- [ ] Is active voice used at least 80% of the time?
- [ ] Does it explain WHY, not just WHAT?
- [ ] Is there at least one concrete, specific example?
- [ ] Are technical terms defined on first use?
- [ ] Does a diagram appear where it would help (5+ mark answers)?
- [ ] Is the conclusion a genuine takeaway (not "In conclusion, X is important")?
- [ ] Would a professor hand this to students without editing?

### Step 7 — Ensure Complete Coverage

After generating all answers:

1. Cross-check: every `question_id` in the extraction output has a matching
   `answer_id` in the answer output.
2. If any question was skipped, go back and generate the answer.
3. For OR/choice questions, confirm both alternatives are answered.
4. Count total answers and compare to total questions — they must match.

---

## Expected Outputs

| Output | Format | Description |
|--------|--------|-------------|
| `answers` | Array per `schemas/answer.schema.json` | Model answers for every question |
| `answer_quality_report` | Markdown | Per-answer quality scores and checklist results |
| `coverage_verification` | JSON | question_id → answer_id mapping, with any gaps flagged |
| `diagram_assets` | Mermaid code blocks within answers | All diagrams embedded in answer content |

---

## Validation Requirements

- [ ] Every question has a corresponding answer — zero gaps.
- [ ] Every answer's word count is within the mark-wise range (±15% tolerance).
- [ ] No answer contains any of the 20 banned AI clichés.
- [ ] Every answer with 5+ marks includes at least one diagram or table.
- [ ] Numerical answers show every step and include unit verification.
- [ ] Code answers compile/run correctly and include sample output.
- [ ] The human writing checklist passes for every answer.
- [ ] `structure_type` in each answer object matches the question type template.
- [ ] All answers conform to `schemas/answer.schema.json`.

---

## Error Handling

| Error | Response |
|-------|----------|
| Topic research missing for a question | Generate answer using internal knowledge. Flag as `"limited_research"`. Add a caveat. |
| Marks not specified for a question | Infer from paper structure (section marks ÷ questions). Note the inference. |
| Question text is ambiguous or garbled | Interpret the most likely intent. Note the ambiguity. Generate the best possible answer. |
| Diagram tool unavailable | Use Mermaid code blocks. If Mermaid isn't renderable, use labeled ASCII art. |
| Programming question with unknown language | Default to the most common language for the subject (Python for CS, C for systems). Note assumption. |
| Formula contains special symbols OCR missed | Attempt reconstruction from context. Flag for user review. |
| Answer exceeds word limit | Tighten the prose. Remove redundant examples. Never cut essential content. |
| Answer is too short for the marks | Add a relevant example, a diagram, or expand the explanation. Never pad with filler. |

---

## Completion Criteria

This workflow is **complete** when:

1. Every question in the paper has a generated answer.
2. All OR/choice alternatives are covered.
3. Every answer passes the human writing checklist.
4. Word counts fall within mark-wise tolerances.
5. All answers conform to `schemas/answer.schema.json`.
6. The coverage verification report shows zero gaps.
7. Quality scores (naturalness, clarity, accuracy, completeness) are ≥ 0.7
   for every answer.
