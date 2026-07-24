---
name: key-insights
description: Distill the key insights from long-form content. Use when the user shares an article or blog URL, a YouTube video or URL, or pastes text and asks for the key insights, main takeaways, or key points.
---

# Key Insights

Distill an article or video down to its **insights** — the transferable claims worth keeping. An insight is not a recap of what the source covers; it is a claim the reader can carry away and use.

## Steps

1. **Acquire the full source.** Identify the input and get its complete text in hand:
   - **Article / blog URL** — fetch the page and extract the readable body. If the fetch returns navigation, boilerplate, a paywall stub, or truncated text instead of the full article, acquisition is incomplete: refetch, try a reader view, or ask the user to paste the text.
   - **YouTube URL** — pull the transcript with `./assets/fetch_transcript.sh "<URL>"`, which prints the title and a `[MM:SS]`-stamped transcript. If it fails or needs adapting, read [references/youtube-transcript.md](references/youtube-transcript.md).
   - **Pasted text or local file** — use it directly.

   Completion criterion: the complete body or transcript is in hand. If acquisition fails, stop and report it — never distill from the title, description, or memory.

2. **Distill the insights** per the rubric below. Completion criterion: every listed insight passes all three tests, the anchors span the source front to back (a video's last anchor sits near its final timestamp, proving the whole thing was read), and no bullet merely recaps what the source is about.

3. **Report** in the output format below.

## What counts as an insight

An insight is a **transferable claim**: the author's actual argument, a surprising fact or number, a mental model, a contrarian take, or an actionable heuristic. Each one passes three tests:

- **Standalone** — a complete claim on its own, understandable without the source. "Caching matters" fails; "Cache-invalidation cost grows with read fan-out, so denormalize before you shard" passes.
- **Non-obvious** — the reader could not have written it from the title alone. Setup and common knowledge everyone already assumes are not insights.
- **Anchored** — each insight carries an **anchor** back to the source: a short quote for text, a `[MM:SS]` timestamp for video.

Extract as many as the source genuinely carries — a dense essay may yield a dozen, a thin video two or three. Draw them from across the whole source, never pad to a number, and never invent a claim the source does not make. Group insights under short theme headings only when there are enough to warrant it.

## Output format

Lead with the source, then the insights:

```
## <Title> — <author or channel>
<source URL>

- **<crisp claim>.** <one sentence of substance or why it matters.> — _<anchor>_
- ...
```
