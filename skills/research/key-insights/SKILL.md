---
name: key-insights
description: Distill the key insights from long-form content. Use when the user shares an article or blog URL, a YouTube video or URL, or pastes text and asks for the key insights, main takeaways, or key points.
---

# Key Insights

Distill long-form content down to its **insights** — the transferable claims worth keeping. An insight is not a recap of what the source covers; it is a claim the reader can carry away and use.

## Steps

1. **Acquire the full source.** Identify the input and get its complete text in hand:
   - **Article / blog URL** — run `defuddle parse "<URL>" --markdown`. Verify that the result has the article's opening, developed body, and actual ending, with coherent prose rather than navigation, boilerplate, a paywall stub, or an abrupt cutoff. If any part is missing, retry with another available reader or ask the user to paste the text.
   - **YouTube URL** — run `./assets/fetch_transcript.sh "<URL>"`, which prints the title and a `[MM:SS]`-stamped transcript. If fetching fails or needs adapting, follow [references/youtube-transcript.md](references/youtube-transcript.md); a network failure is not evidence that captions are absent.
   - **Pasted text or local file** — use it directly.

   Completion criterion: the source is available from its substantive opening through its ending. If acquisition fails, stop and report it — never distill from a title, description, snippet, or memory.

2. **Map the source front to back.** Identify its argument, substantive sections, and conclusion. If it presents an explicit bounded list — ideas, categories, habits, principles, steps, or similar named entries — record every item in source order for a **list overview**. A list overview is coverage, not distillation: summarize each item in one line even when it is obvious or not insightful.

   Completion criterion: every substantive section has been assessed, and every item in a bounded list has been accounted for exactly once.

3. **Distill the insights** per the rubric below. Completion criterion: every listed insight passes all three tests, collectively represents the source's substantive argument rather than only its opening, and no insight merely recaps a topic or list item.

4. **Report** using the output format below. Print the result in the response unless the user requested a file. If the source has no title, supply a short descriptive one. For a file, slugify that title as `<title-slug>.md`.

## What counts as an insight

An insight is a **transferable claim**: the author's actual argument, a surprising fact or number, a mental model, a contrarian take, or an actionable heuristic. Each one passes three tests:

- **Standalone** — a complete claim on its own, understandable without the source. "Caching matters" fails; "Cache-invalidation cost grows with read fan-out, so denormalize before you shard" passes.
- **Non-obvious** — the reader could not have written it from the title alone. Setup and common knowledge everyone already assumes are not insights.
- **Anchored** — each insight points to the passage that supports it: a brief distinctive quote for written or pasted text, or the nearest `[MM:SS]` timestamp for video. The anchor must let the reader find and verify the claim; it is not a substitute for stating the claim clearly.

Extract as many as the source genuinely carries — a dense essay may yield a dozen, a thin video two or three. Draw them from across the whole source, never pad to a number, and never invent a claim the source does not make. Group insights under short theme headings only when there are enough to warrant it.

## Output format

Lead with the source. Include the author or channel only when known. Use the URL for a remote source, the path for a local file, or `User-provided text` for pasted content.

For a source built around an explicit bounded list, insert a compact overview before the insights. Preserve the source's order and account for every item; do not force the overview entries to pass the insight tests.

```
## <Title>[ — <author or channel>]
<URL, local path, or User-provided text>

### List overview

1. **<item name>** — <one-line explanation>
2. ...

### Key insights

- **<crisp claim>.** <one sentence of substance or why it matters.> — _<anchor>_
- ...
```

Omit `List overview` when the source is not organized around a bounded list. The insights may follow the source line directly when separate headings would add no clarity.
