# Workflow 06 — Deep Topic Research

## Title

Deep Topic Research and Knowledge Acquisition

## Objective

Research every topic covered by the extracted questions and syllabus in depth,
producing verified, well-sourced knowledge that downstream workflows (answer
generation, notes, question bank) can draw from directly.

---

## Required Inputs

| Input | Source | Required? |
|-------|--------|-----------|
| Extracted questions list | `workflows/01-paper-extraction.md` output | Yes |
| Syllabus topic map | `workflows/03-syllabus-research.md` output | Yes (if available) |
| Question analysis data | `workflows/05-question-analysis.md` output | Yes |
| Research priority config | `config/research-priority.yaml` | Yes |
| Language rules | `config/language-rules.yaml` | Yes |
| User-uploaded materials | PDFs, notes, textbook excerpts provided by student | Optional |

---

## Step-by-Step Instructions

### Step 1 — Build the Master Topic List

1. Collect every unique topic from the question analysis output.
2. Collect every topic from the syllabus map (if available).
3. Merge both lists, removing duplicates but preserving all unique entries.
4. For each topic, record:
   - `topic_id` and `topic_name`
   - `unit_number` (from syllabus)
   - `importance_level` (from question frequency: critical / high / medium / low)
   - `prerequisite_topics` (topics that must be understood first)
5. Sort the list by importance: critical first, low last.

### Step 2 — Identify Prerequisites

For each topic, ask: "Can a student understand this without first knowing something else?"

- If yes → add the prerequisite to the master list (if not already there).
- Mark prerequisite topics for research even if they don't appear in the paper.
- Example: "B+ Tree" requires understanding of "Binary Search Tree" and "Indexing."

### Step 3 — Research Each Topic

For every topic in the master list, research and document these aspects.
**Include only the aspects that genuinely apply — don't force every section.**

| Aspect | What to Capture |
|--------|-----------------|
| **Definition** | Clear, exam-ready definition in simple English |
| **Basic Concepts** | Foundational ideas the student needs before going deeper |
| **Working Principles** | How it works, step by step |
| **Components / Parts** | Key building blocks or elements |
| **Characteristics** | Defining properties or features |
| **Types / Classifications** | Categories, variants, or sub-types |
| **Advantages** | Why it's useful or preferred |
| **Disadvantages** | Limitations, drawbacks, or trade-offs |
| **Applications** | Where it's used in practice (real examples, not generic ones) |
| **Practical Examples** | Concrete, specific examples a student can visualize |
| **Comparisons** | How it differs from similar or competing concepts |
| **Related Concepts** | Topics that connect to or extend this one |
| **Important Terminology** | Key terms a student must know for the exam |
| **Common Mistakes** | Errors students frequently make on this topic |

### Step 4 — Apply Source Priority and Reliability Ranking

Follow the source priority order from `config/research-priority.yaml`:

```
PRIORITY 1 (Highest) — Official university materials
PRIORITY 2 — Prescribed textbooks
PRIORITY 3 — Government / regulatory body resources (UGC, AICTE, NCERT)
PRIORITY 4 — Peer-reviewed academic papers (IEEE, ACM, Springer)
PRIORITY 5 — Reputable academic websites (.edu, NPTEL, MIT OCW)
PRIORITY 6 — Official technical documentation (Python docs, MDN, Oracle)
PRIORITY 7 — Community platforms (Stack Overflow top answers, Wikipedia)
```

**Source reliability scoring:**

| Tier | Trust Score | Rule |
|------|-------------|------|
| Tier 1 (Priority 1–2) | 0.9–1.0 | Accept directly. These define what the examiner expects. |
| Tier 2 (Priority 3–4) | 0.7–0.9 | Accept after one cross-check with another source. |
| Tier 3 (Priority 5–6) | 0.5–0.7 | Accept only if confirmed by a Tier 1 or Tier 2 source. |
| Tier 4 (Priority 7) | 0.3–0.5 | Use for supplementary understanding only. Never cite alone. |

**Never accept information from a single Tier 4 source as fact.**

### Step 5 — Cross-Verify Facts

Every factual claim must pass the **two-source rule**:

1. Find the claim in at least two independent sources.
2. If only one source confirms it, flag it with `[single-source]` and note which.
3. If two sources contradict each other:
   - Follow the conflict resolution rules in `config/research-priority.yaml`.
   - Prefer the higher-priority source for exam answers.
   - Note the discrepancy so the student is aware.
4. For numerical values, formulas, and code — verify independently (run the code
   or re-derive the formula when possible).

### Step 6 — Write Original Explanations

- **Never copy large portions** of text from any source.
- Read, understand, then explain in your own words.
- Follow all rules in `config/language-rules.yaml`:
  - Simple vocabulary, active voice, real examples.
  - No banned phrases or AI clichés.
  - Explain WHY, not just WHAT.
- Technical terms must be defined in plain English on first use.
- Target vocabulary level: undergraduate student with no prior exposure.

### Step 7 — Cite Important Sources

For each topic's research output, record:

```
sources:
  - source_id: "src-001"
    category: "prescribed_textbook"
    title: "Database System Concepts"
    authors: "Silberschatz, Korth, Sudarshan"
    trust_score: 0.95
    used_for: "Definition and normalization examples"
```

- Cite the source that informed each major claim.
- Don't over-cite — one citation per key fact or section is enough.
- If no external source was used (agent's own knowledge), note it as
  `category: "internal_knowledge"` with `trust_score: 0.5`.

### Step 8 — Handle Topics with Limited Information

When a topic has sparse or no reliable sources:

1. **Don't fabricate.** State what is known and stop.
2. Add a limitation note: `"Limited reliable sources found for this topic.
   Content is based on general knowledge and may need verification."`
3. Recommend the student check their class notes or ask their professor.
4. If the topic is likely a university-specific concept (e.g., a custom
   framework taught only in that college), rely on user-uploaded materials
   and state the limitation clearly.

### Step 9 — Research Prerequisite Concepts

When you encounter a topic that depends on prior knowledge:

1. Check if the prerequisite is already in the master topic list.
2. If not, add it with `importance_level: "supporting"`.
3. Research it at a lighter depth — just enough for the student to understand
   the main topic. No need for a full deep-dive on prerequisites.
4. Cross-link: in the prerequisite's notes, mention which topics build on it.

---

## Offline Mode — When Internet Is Not Available

When internet access is unavailable, the research workflow degrades gracefully:

1. **Use only uploaded materials.** The student's PDFs, notes, and textbook
   excerpts become the primary (and only) sources.
2. **Use internal knowledge.** The agent's training data covers standard
   academic topics well enough for a solid foundation.
3. **Skip PYQ web searches.** If previous papers weren't uploaded, skip the
   frequency analysis entirely.
4. **Disclose the limitation.** Add this notice to every output:

   > ⚠️ **Offline Mode:** This content was generated without internet access.
   > Research is based on uploaded materials and general knowledge only.
   > Verify key facts against your prescribed textbook before the exam.

5. **Do NOT pretend to have searched the web.** Never cite a URL you didn't
   actually visit. Never claim cross-verification that didn't happen.
6. **Prioritize accuracy over completeness.** It's better to cover 80% of
   topics accurately than to guess at 100%.

---

## Expected Outputs

| Output | Format | Description |
|--------|--------|-------------|
| `topic_research_data` | Array of objects per `schemas/topic.schema.json` | Complete research data for each topic |
| `source_registry` | Array per `schemas/research-source.schema.json` | All sources consulted, with trust scores |
| `prerequisite_map` | JSON object | Topic → prerequisite relationships |
| `research_coverage_report` | Markdown table | Topic → researched (yes/no) → depth → source count |
| `limitation_notes` | Array of strings | Topics with insufficient sources or caveats |

---

## Validation Requirements

- [ ] Every question topic from the paper has a corresponding research entry.
- [ ] Every syllabus topic (if syllabus was found) has at least a basic entry.
- [ ] No topic has zero sources — at minimum, `internal_knowledge` is recorded.
- [ ] All factual claims pass the two-source rule (or are flagged as single-source).
- [ ] No banned phrases from `config/language-rules.yaml` appear in any output.
- [ ] Source trust scores are assigned according to the tier table above.
- [ ] Prerequisite topics are identified and researched.
- [ ] Offline mode disclosure is present when internet was not available.

---

## Error Handling

| Error | Response |
|-------|----------|
| Internet unavailable | Switch to offline mode. Use uploaded materials + internal knowledge. Disclose limitation. |
| Topic not found in any source | Record as `limited_information`. Add limitation note. Rely on internal knowledge. |
| Conflicting information across sources | Follow conflict resolution rules from `config/research-priority.yaml`. Note both versions. |
| OCR / extraction produced garbled topic names | Attempt to infer correct topic name from context. Flag for user review if ambiguous. |
| Source website unreachable or returns errors | Skip that source. Try next-priority source. Note the gap in source registry. |
| Syllabus not available | Research only the topics found in the question paper. Note reduced coverage. |
| User-uploaded material is unreadable | Notify user. Ask for a clearer copy. Continue with available sources. |

---

## Completion Criteria

This workflow is **complete** when:

1. Every topic in the master list has a research entry with at least a definition,
   basic concepts, and one example.
2. The source registry contains all consulted sources with trust scores.
3. The research coverage report shows ≥ 90% of topics fully researched
   (or all gaps are explained in limitation notes).
4. Cross-verification has been performed on all critical and high-importance topics.
5. All outputs conform to their respective schemas.
6. The prerequisite map is complete and consistent (no circular dependencies).
7. No text violates the language rules or contains banned phrases.
