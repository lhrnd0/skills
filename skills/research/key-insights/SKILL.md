---
name: key-insights
description: Distill long-form content into a concise overview and anchored key insights. Use when the user shares an article or blog URL, a YouTube video or URL, or pastes text and asks for the key insights, main takeaways, key points, or a summary.
---

# Key Insights

Turn long-form content into a concise overview plus **insights** — the transferable claims worth keeping. An insight is not a recap of what the source covers; it is a claim the reader can carry away and use.

## Steps

1. **Acquire the full source.** Identify the input and get its complete text in hand:
   - **Article / blog URL** — fetch the page and extract the readable body. If the fetch returns navigation, boilerplate, a paywall stub, or truncated text instead of the full article, acquisition is incomplete: refetch, try a reader view, or ask the user to paste the text.
   - **YouTube URL** — pull the transcript with `./assets/fetch_transcript.sh "<URL>"`, which prints the title and a `[MM:SS]`-stamped transcript. If it fails or needs adapting, read [references/youtube-transcript.md](references/youtube-transcript.md).
   - **Pasted text or local file** — use it directly.

   Completion criterion: the complete body or transcript is in hand. If acquisition fails, stop and report it — never distill from the title, description, or memory.

2. **Map and summarize the source front to back.** Identify its subject, central argument, substantive sections, and conclusion. Write a concise **overview** that describes the source as a whole, including its main thesis and scope, in two to four sentences. If it presents an explicit bounded list — ideas, categories, habits, principles, steps, or similar named entries — also record every item in source order for a **list overview**. A list overview is coverage, not distillation: summarize each item in one line even when it is obvious or not insightful.

   Completion criterion: the overview accurately represents the full source rather than only its opening, every substantive section has been assessed, and every item in a bounded list has been accounted for exactly once.

3. **Distill the insights** per the rubric below. Completion criterion: every listed insight passes all three tests, the anchors span the source front to back (a video's last anchor sits near its final timestamp, proving the whole thing was read), and no bullet merely recaps what the source is about.

4. **Report.** Write the report in the source language when it is English or Portuguese; for every other source language, write it in English. First ask whether the user wants the output written to a file or printed to the screen. If a file, slugify the title and create `<title-slug>.md`; otherwise print to the screen. Either way, use the output format below.

## What counts as an insight

An insight is a **transferable claim**: the author's actual argument, a surprising fact or number, a mental model, a contrarian take, or an actionable heuristic. Each one passes three tests:

- **Standalone** — a complete claim on its own, understandable without the source. "Caching matters" fails; "Cache-invalidation cost grows with read fan-out, so denormalize before you shard" passes.
- **Non-obvious** — the reader could not have written it from the title alone. Setup and common knowledge everyone already assumes are not insights.
- **Anchored** — each insight carries an **anchor** back to the source: a short quote for text, a `[MM:SS]` timestamp for video.

Extract as many as the source genuinely carries — a dense essay may yield a dozen, a thin video two or three. Draw them from across the whole source, never pad to a number, and never invent a claim the source does not make. Group insights under short theme headings only when there are enough to warrant it.

## Output format

Lead with the source, then provide the overview and insights. For a source built around an explicit bounded list, follow the overview with a compact list overview. Preserve the source's order and account for every item; do not force the list overview entries to pass the insight tests.

```
## <Title> — <author or channel>
<source URL>

### Overview

<Two to four sentences describing the source's subject, central thesis, scope, and conclusion.>

### List overview

1. **<item name>** — <one-line explanation>
2. ...

### Key insights

- **<crisp claim>.** <one sentence of substance or why it matters.> — _<anchor>_
- ...
```

Omit `List overview` when the source is not organized around a bounded list. Always retain `Overview` and `Key insights`.
