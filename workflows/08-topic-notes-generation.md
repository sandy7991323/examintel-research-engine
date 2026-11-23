# Workflow 08 — Topic Notes Generation

## Title

Unit-Wise Study Notes Generation

## Objective

Generate complete, unit-wise study notes covering the entire syllabus. Notes
must be self-contained, study-ready, written in natural human English, and
organized so a student can read them front-to-back and understand every topic
without needing another resource.

---

## Required Inputs

| Input | Source | Required? |
|-------|--------|-----------|
| Syllabus topic map | `workflows/03-syllabus-research.md` output | Yes |
| Topic research data | `workflows/06-deep-topic-research.md` output | Yes |
| Question analysis | `workflows/05-question-analysis.md` output | Recommended |
| Answer length rules | `config/answer-length-rules.yaml` | Yes |
| Language rules | `config/language-rules.yaml` | Yes |
| Source registry | `workflows/06-deep-topic-research.md` output | Yes |
| Previous year frequency data | `workflows/04-previous-paper-research.md` output | Optional |

---

## Step-by-Step Instructions

### Step 1 — Organize Topics by Syllabus Units

1. Group all researched topics under their respective syllabus units.
2. Within each unit, order topics logically:
   - Prerequisites before topics that depend on them.
   - Foundational concepts before advanced ones.
   - Follow the syllabus order when no dependency exists.
3. Create a table of contents structure:

```
Unit 1: [Unit Title]
  ├── Topic 1.1: [Topic Name]
  ├── Topic 1.2: [Topic Name]
  └── Topic 1.3: [Topic Name]
Unit 2: [Unit Title]
  ├── Topic 2.1: [Topic Name]
  ...
```

4. If a topic spans multiple units, place it in the primary unit and add a
   cross-reference in the secondary unit.

### Step 2 — Determine Topic Depth by Exam Importance

Not every topic gets the same depth. Use exam frequency and marks data to
set the appropriate level:

| Importance Level | Criteria | Depth | Sections to Include |
|-----------------|----------|-------|---------------------|
| **Critical** | Asked 3+ times in PYQs, or carries 10+ marks | Full deep-dive | All relevant sections, multiple examples, diagrams |
| **High** | Asked 2+ times, or carries 5–9 marks | Thorough coverage | Most sections, at least one example and diagram |
| **Medium** | Asked once, or is a syllabus topic not yet tested | Standard coverage | Core sections — definition, explanation, example |
| **Low** | Minor subtopic or supporting concept | Brief coverage | Definition + key points + one example |
| **Supporting** | Prerequisite not in syllabus but needed for understanding | Minimal | Definition + enough context to understand the main topic |

### Step 3 — Generate Notes for Each Topic

For each topic, select the relevant sections from the pool below.
**Do NOT force all sections into every topic.** Only include sections that
genuinely help the student understand and prepare for the exam.

#### Available Sections Pool

| Section | When to Include | What to Write |
|---------|----------------|---------------|
| **Introduction** | When the topic needs context-setting | 2–4 sentences: what this topic is about and why it matters. No generic filler. |
| **Definition** | Almost always (skip only for purely procedural topics) | A clear, memorable definition. If the textbook definition is jargon-heavy, rewrite it in plain English and then give the formal version. |
| **Basic Concept** | When the topic has a core idea that everything else builds on | The fundamental principle, explained simply. Use an analogy if it helps. |
| **Detailed Explanation** | For medium-to-critical topics | The full "how it works" treatment. Break complex ideas into numbered steps or sub-sections. |
| **Types / Classification** | When the topic has well-defined categories | Present types in a table or list. For each type: name, brief description, one example, when it's used. |
| **Characteristics** | When the topic has defining properties worth listing | Bullet list of key features. Each bullet: the characteristic + why it matters. |
| **Working Principle** | For mechanisms, algorithms, protocols, processes | Step-by-step walkthrough. Use numbered steps. Add a flowchart if the process has branches. |
| **Advantages** | When explicitly asked in PYQs or when it adds value | Numbered list. Each advantage: what it is + a one-line "because" explanation. |
| **Disadvantages** | Same as advantages — pair them together | Same format. Don't just negate the advantages — give real limitations. |
| **Applications** | For topics with real-world use cases | 3–5 specific, concrete applications. Not "used in many industries" — name the industry and what exactly it does there. |
| **Practical Examples** | Almost always (this is what makes notes memorable) | A scenario the student can picture. Walk through it step by step. |
| **Diagrams** | For any topic where a visual representation aids understanding | Mermaid/SVG diagrams with labels and captions. Explain what the diagram shows in 2–3 sentences after it. |
| **Related Concepts** | When connections to other topics help build a bigger picture | Brief pointers: "See also: [Topic X] for how this connects to..." |
| **Important Terminology** | When the topic introduces specialized terms | A mini-glossary: term → plain-English definition. |
| **Exam Questions** | For critical and high-importance topics | 2–5 sample questions from PYQs that test this topic. Include marks and year if known. |
| **Quick Revision Notes** | For all topics | 5–8 bullet points that capture the absolute essentials. A student should be able to read these 10 minutes before the exam. |

### Step 4 — Section Selection Decision Tree

For each topic, run through this decision process:

```
1. Is it a concept, mechanism, or both?
   → Concept: Include Definition, Basic Concept, Characteristics
   → Mechanism: Include Working Principle, Diagrams
   → Both: Include all of the above

2. Does it have categories or variants?
   → Yes: Include Types / Classification
   → No: Skip

3. Has it been asked in a "discuss advantages/disadvantages" format?
   → Yes: Include Advantages + Disadvantages
   → No: Include only if they add genuine value

4. Is it testable with a numerical or coding problem?
   → Yes: Include Practical Examples with worked solutions
   → No: Include a conceptual example

5. Does a visual aid help understanding?
   → Yes: Include Diagrams (flowchart, block diagram, etc.)
   → No: Skip — don't add diagrams for decoration

6. Does it connect to other syllabus topics?
   → Yes: Include Related Concepts
   → No: Skip
```

### Step 5 — Explain Prerequisites Inline

When a topic depends on prior knowledge:

1. Check if the prerequisite has its own section in the notes.
2. If yes → add a brief cross-reference: "Before reading this, review
   [Topic Name] in Unit X."
3. If no → include a "Background" mini-section (3–5 sentences) that covers
   just enough of the prerequisite for the student to follow along.

The goal: a student reading the notes in order should never hit a concept
they can't understand because something wasn't explained yet.

### Step 6 — Make Notes Self-Contained and Study-Ready

Each topic's notes must work as a standalone study unit:

- A student should be able to read the topic, understand it, and answer
  exam questions on it — without needing another book open.
- Include enough examples that the concept "clicks."
- Include enough practice questions that the student knows what the
  examiner expects.
- End each unit with a "Unit Summary" section: 10–15 bullet points
  covering the key takeaways from all topics in that unit.

### Step 7 — Apply Human Writing Rules Throughout

Every line of the notes must follow the writing rules from
`config/language-rules.yaml` and the SKILL.md Golden Rules:

- Simple vocabulary, natural flow, varied sentence length.
- Active voice by default. Passive voice only when the actor is irrelevant.
- Real examples, not abstract hand-waving.
- No banned phrases — zero tolerance.
- Contractions are fine. Address the reader as "you" when appropriate.
- Explain WHY things work the way they do.
- Technical terms defined in plain English on first use.

### Step 8 — Add Visual Elements

- Use Mermaid diagrams for: flowcharts, block diagrams, state machines,
  sequence diagrams, ER diagrams, class diagrams.
- Use Markdown tables for: comparisons, feature lists, type classifications.
- Use inline code formatting for: variable names, function names, commands.
- Use fenced code blocks for: code examples, algorithm pseudocode.
- Label every figure: `**Figure X.Y:** [Caption describing what this shows]`

---

## Expected Outputs

| Output | Format | Description |
|--------|--------|-------------|
| `unit_notes` | Markdown files (one per unit or one master file) | Complete study notes organized by syllabus units |
| `topic_coverage_map` | Markdown table | Topic → included (yes/no) → depth level → sections included |
| `cross_reference_index` | JSON | Topic → related topics → prerequisite topics |
| `revision_bullets` | Markdown section at end of each unit | Quick-revision bullet points per unit |

---

## Validation Requirements

- [ ] Every syllabus topic has a corresponding notes section (or is explained
      why it was excluded).
- [ ] Critical-importance topics have full deep-dive coverage (definition +
      explanation + examples + diagrams + practice questions).
- [ ] No topic is missing a definition (unless it's purely procedural).
- [ ] Every topic with PYQ history includes at least one sample exam question.
- [ ] No banned phrases or AI clichés appear anywhere in the notes.
- [ ] All diagrams have captions and are explained in the surrounding text.
- [ ] Prerequisites are either cross-referenced or explained inline.
- [ ] Each unit ends with a summary section.
- [ ] Notes are self-contained: a student can study from them alone.
- [ ] Topic depth matches the importance level from Step 2.

---

## Error Handling

| Error | Response |
|-------|----------|
| Syllabus not available | Organize notes by the topics found in the question paper. Group by inferred units if possible. Note the limitation. |
| Topic research data is incomplete | Generate notes with available information. Mark thin sections with `[needs verification]`. |
| PYQ frequency data missing | Treat all topics as medium importance. Note that depth wasn't frequency-calibrated. |
| Diagram rendering unavailable | Use Mermaid code blocks (they render in most Markdown viewers). Fallback to ASCII art. |
| Topic is too broad for a single section | Split into sub-topics. Create a parent overview section and then sub-sections. |
| Two topics overlap significantly | Merge into one section with a combined title. Add cross-references from both original locations. |
| Notes exceed a reasonable length | Prioritize critical topics. Trim low-importance topics to definition + key points only. |

---

## Completion Criteria

This workflow is **complete** when:

1. Notes exist for every unit in the syllabus.
2. Every topic within each unit has notes at the appropriate depth level.
3. The topic coverage map shows ≥ 95% coverage (gaps have documented reasons).
4. All notes pass the language quality check (`quality-checks/language-check.md`).
5. All diagrams render correctly in Mermaid syntax.
6. Cross-references are consistent (no broken links to nonexistent topics).
7. Each unit has a summary section with quick-revision bullets.
8. A student reading the notes end-to-end encounters no unexplained concepts.
