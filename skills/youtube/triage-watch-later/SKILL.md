---
name: triage-watch-later
description: Triage a signed-in user's YouTube Watch Later playlist one video at a time with grounded reports and delete, Readwise Reader, browser, and on-demand key-insights actions.
disable-model-invocation: true
---

# Triage YouTube Watch Later

Keep the queue as a current `yt-dlp` snapshot and present exactly one video per turn. Act only after the user chooses an action.

## Setup

1. Run [`scripts/fetch_watch_later.sh`](scripts/fetch_watch_later.sh), resolved relative to this skill. It uses `YOUTUBE_COOKIES_FILE` when set; otherwise it uses `YOUTUBE_BROWSER` or its first argument with `yt-dlp --cookies-from-browser`. If neither source is configured, ask the user for a supported signed-in browser name or a Netscape cookie-file path. Never probe browser profiles or print cookie contents.

   Completion criterion: the helper returns valid JSON containing `count` and the ordered `videos` array, or authentication fails with a concrete next step for the user.

2. Start with the first untriaged video in the returned order. Record its video ID, canonical URL, title, channel, duration, position, and queue count. Treat the video ID as its stable identity; positions can change after removal.

   Completion criterion: every action can target the current video without relying on its old row position.

3. Ground the report in available metadata. Fetch public metadata with `yt-dlp --skip-download --dump-single-json "<url>"` when available. Use the description, chapter titles, upload date, duration, channel, and other substantive metadata. State a lower confidence when only sparse metadata is available; never infer the video's substance from its title alone. Reserve transcript acquisition and `$key-insights` for the **Key insights** action.

   Completion criterion: every claim in the report is supported by inspected metadata or source content, and its confidence reflects the evidence available.

## Report

Present only the current video. Use this format:

```markdown
### {position}/{total} · {title}

{channel} · {duration} · {published date when known}
[{canonical YouTube URL}]({canonical YouTube URL})

**What it is:** {2–4 sentence synthesis}

**Why watch:** {an opinionated reason this may deserve the user's time}

**Why skip:** {an honest reason it may not be worth the time or may be redundant}

**Confidence:** {High from source content | Medium from substantive metadata | Low from sparse metadata}

**Actions**

- **Delete** — remove from Watch Later
- **Add to Readwise Reader** — save to Reader, then remove from Watch Later after the save is verified
- **Open in browser** — open the video and keep this report active
- **Key insights** — extract grounded, timestamped insights on demand
```

Use `reader_persona.md` from the current working directory when present to personalize `Why watch` and `Why skip`. Proceed without it and avoid announcing its absence.

## Actions

### Delete

Follow the `control-in-app-browser` skill, open Watch Later in a signed-in browser, find the current row by video ID, and use its menu to choose **Remove from Watch later**. Re-run `scripts/fetch_watch_later.sh` and advance only when the returned queue excludes that video ID.

Completion criterion: the exact video ID is absent from Watch Later before advancing.

### Add to Readwise Reader

Use a Readwise connector or MCP tool when available; otherwise use the `readwise` CLI. Save the canonical video URL with `reader_create_document(url="<url>", title="<title>")` or `readwise reader-create-document --url "<url>" --title "<title>"`. Treat an already-existing Reader document as a successful handoff.

After verifying the save or existing document, follow the **Delete** action and advance only after the refreshed CLI queue excludes the video ID. If the Reader operation fails, leave Watch Later unchanged, report the failure briefly, and re-present the same video's actions.

Completion criterion: Reader contains the canonical URL and the video ID is absent from Watch Later before advancing.

### Open in browser

Open the canonical URL in a new tab so the playlist tab and current identity remain intact. Keep the current video active; when the user returns, re-present its four actions. If the user says they watched or finished it, ask whether to delete it or add it to Reader.

Completion criterion: the video is open and no playlist or Reader state has changed.

### Key insights

Only after the user chooses **Key insights**, execute `$key-insights` from `skills/research/key-insights` for the current video's canonical URL. Present its complete result under a `#### Key insights` heading, then re-present the four actions for the same video. Keep the playlist and Reader unchanged. If insight extraction fails, show the failure briefly and re-present the same actions.

Completion criterion: the on-demand insights or acquisition failure are shown for the exact current video, and that video remains active.

## Loop invariants

- Show one video at a time; never preview the next report in the same turn.
- Re-run the fetch helper after each removal instead of trusting cached positions.
- Generate key insights only after the user selects that action.
- Keep the current video active after failures and non-mutating actions.
- Stop when the playlist is empty and report how many videos were deleted, handed to Reader, and opened during the session.
