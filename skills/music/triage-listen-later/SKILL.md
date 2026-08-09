---
name: triage-listen-later
description: Triage Readwise Reader items tagged garimpo with release research, acquisition links, download notes, and optional local wishlist tracking.
disable-model-invocation: true
---

# Triage Listen Later

Treat the `garimpo` tag as a music-discovery queue. Research and present exactly one item, then wait for the user's action.

## Fetch the queue

1. Use Readwise MCP tools when available; otherwise follow `$readwise-cli`. List documents with the exact `garimpo` tag across Reader locations. Request `title`, `author`, `category`, `summary`, `url`, `source_url`, `site_name`, `published_date`, `saved_at`, `reading_time`, `location`, `tags`, and `notes`. Exclude documents already tagged `download` and IDs handled during this session.

   MCP shape: `reader_list_documents(tag=["garimpo"], limit=10, response_fields=[...])`.

   CLI shape: `readwise --json reader-list-documents --tag garimpo --limit 10 --response-fields title,author,category,summary,url,source_url,site_name,published_date,saved_at,reading_time,location,tags,notes`.

   Completion criterion: every candidate has its document ID, `saved_at`, current location, tags, notes, and original `source_url`; items lacking `source_url` are retained with that absence recorded.

2. Select the item using the mode implied by the user's request:

   - **Recent** is the default. Sort eligible documents by `saved_at` descending and take the newest, using the document ID as the stable tie-breaker. Fetch subsequent pages only when the current batch has no eligible item.
   - **Random** applies when the user requests random or shuffle mode. Traverse every page of the eligible queue, then choose one document ID uniformly at random. Keep random mode for the session unless the user changes it.

   Construct `wiseread://read/{id}` and retain the Reader web `url` separately from the original `source_url`. Use the document ID as the stable identity throughout the turn.

   Completion criterion: the current item was selected by the active mode and can be linked and mutated without relying on its title or position.

## Identify and research the item

1. Inspect the original source and Reader metadata. For supported media URLs, use structured metadata such as `yt-dlp --skip-download --dump-single-json "<source_url>"` when it improves identification. Determine whether the item is a single recording, full release, DJ set, playlist, performance, article, or another type. Resolve artist and title only from evidence.

   Completion criterion: the item type and the best-supported artist/title identity are known, or ambiguity is stated explicitly.

2. For a song or release, research its release context before reporting:

   - Search MusicBrainz by recording plus artist, then inspect linked release groups and releases.
   - Search Discogs by artist plus track or release title; distinguish a master release from a specific edition.
   - Check artist, label, Bandcamp, distributor, or store pages for primary release and acquisition evidence.
   - Use other credible sources only to fill gaps or corroborate identity.

   Verify candidates against artist credit, track title, tracklist inclusion, duration when known, release date, label, catalog number, country, and format. Prefer the original or clearly relevant release; show multiple plausible releases when the evidence does not select one. Never infer an exact pressing or edition from a stream title alone.

   Completion criterion: every presented release match is linked to evidence, and uncertain matches remain visibly uncertain.

3. Build two kinds of download leads:

   - **Search suggestions:** provide two or three copyable queries suitable for Soulseek or another catalog/file-search application. Start with `Artist - Track Title`; add release title, version or remix, label, catalog number, year, or format only when verified and useful for disambiguation. Search suggestions are identifiers, not claims that a file is available or authorized.
   - **Find online:** look for exact release pages on the artist or label store, Bandcamp, Beatport, Juno Download, Traxsource, Boomkat, Qobuz, or another relevant authorized store. Use Discogs marketplace links for physical editions when useful. Prefer a direct item page; label a store-search page as a search rather than a match.

   Present streaming links separately from purchase or download links. Never purchase or download as part of triage.

   Completion criterion: the report contains at least one evidence-based search query and every useful online listening or acquisition route found is linked and labeled by purpose; missing routes are stated.

For a non-song item, adapt the research to its actual type and omit release fields that do not apply.

## Report

Present one item using this structure. Omit unknown fields instead of filling them with guesses.

```markdown
### {position}/{total} · {artist — track or source title}

**Original source:** [{host or descriptive label}]({source_url})
**Reader:** [App](wiseread://read/{id}) · [Web]({url})
{source author/channel · duration when known · saved relative date}

**What it is:** {2–4 sentence identification and listening context}

**Release context:** {release/album title · year · label · catalog number · country · format, as supported}

**Why it may be worth acquiring:** {specific musical, historical, label, scene, version, or availability rationale grounded in the sources}

**Why pass:** {honest reason the item or available edition may not justify time or money}

**Listen:** {linked source and any useful alternate official stream}

**Download search suggestions:**

- Soulseek or equivalent: `{artist} - {track title}`
- Release search: `{artist} {release title} {label or catalog number}`

**Find online:**

- [Bandcamp, Beatport, artist/label store, or other exact page]({URL}) — {purchase/download and format}
- [Discogs]({matched URL}) — {master or edition; include marketplace link separately when useful}

**Release evidence:**

- [MusicBrainz]({matched URL}) — {recording, release group, or release}
- [{artist, label, distributor, or other source}]({URL}) — {identity or release evidence}

**Match confidence:** {High | Medium | Low} — {brief evidence or unresolved ambiguity}

**If acquired:** invoke `$format-music-release` with the local release folder or audio-file path.

**Actions**

- **Listen** — open the original source and keep this item active
- **Download** — add `download`, save the leads to Reader and an existing local wishlist, move to Inbox, and advance
- **Delete** — permanently delete the item from Reader and advance
- **Next** — leave the item untouched and advance to another queue item
- **More research** — deepen the release or acquisition search and keep this item active
```

Retain at least the original source link when no release match exists. Include only source categories that produced a useful link.

## Handle actions

### Listen

Follow `control-in-app-browser` and open the original source. Preserve the current document ID and re-present its actions when the user returns.

Completion criterion: the source is open and Reader state is unchanged.

### Download

1. Resolve the directory containing this `SKILL.md`. Check for `WISHLIST.md` directly inside that directory. Record whether it exists at the start of the action; treat absence as an opt-out and leave the filesystem unchanged. Read [the download record formats](references/download-records.md), then build the Reader note block and, when opted in, the wishlist entry from the verified report.

   Completion criterion: the complete Reader note is ready, and an existing wishlist has one prepared entry keyed by the Reader document ID.

2. Preserve the existing document note and upsert its marked download block. Include every useful link from the report. Add the exact `download` tag, retain `garimpo`, and move the document to Reader Inbox (`location: new`). Prefer an authenticated Readwise mutation tool that can update document notes. Otherwise, send `PATCH https://readwise.io/api/v3/update/{document_id}/` with the existing authentication and a JSON body containing the complete merged `notes` string; use the tag-specific tool for `download` so existing tags are preserved.

   Fetch the document by ID and verify its full note, tags, and location before continuing.

   Completion criterion: `location` is `new`; `garimpo` and `download` are present; and the note preserves its prior content and contains exactly one marked block with the presented search suggestions, links, release context, and confidence.

3. When `WISHLIST.md` existed at the start of the action, upsert the prepared entry without changing unrelated content, then read the entry back from disk. Keep the original queued date when replacing an existing entry. Mark the document ID as handled for the current session only after every applicable write verifies. If any mutation, file edit, or verification fails, keep the item active and report the incomplete state without exposing credentials.

   Completion criterion: the ID will not appear again in this or a later triage session; and, when the wishlist opted in, it contains exactly one complete entry for the Reader document ID. When it opted out, no `WISHLIST.md` was created.

### Delete

Treat the user's **Delete** selection for the active item as confirmation of this destructive action. Prefer an authenticated Readwise tool that permanently deletes a Reader document when one is available. Otherwise, use the official Reader API: send `DELETE` to `https://readwise.io/api/v3/delete/{document_id}/` with the existing Readwise authentication, without displaying or logging the access token. Do not substitute Archive for deletion.

Advance only after the request returns HTTP `204`. On any other response, keep the item active, report the failure without exposing credentials, and do not retry unless the failure is clearly transient.

Completion criterion: Reader returns HTTP `204` for the exact active document ID, and that ID is marked handled for the current session.

### Next

Issue no Reader mutation for the active document. Add its ID only to the in-memory handled set for this session, then advance using the active selection mode. Its location, tags, notes, and all other Reader fields remain unchanged, so it may appear again in a future triage session.

Completion criterion: no mutation request was issued for the active document, its ID is excluded for the rest of this session, and the next report is for a different eligible ID.

### More research

Follow the unresolved evidence named in `Match confidence`. Inspect the most discriminating source next—tracklist, label/catalog page, artist page, or alternate edition—and update the same report with links. Preserve Reader state and keep the item active.

Completion criterion: the named ambiguity is resolved or the report identifies the exact missing evidence that prevents resolution.

## Loop

Use `· · ·` before the next report. Continue with the active selection mode, excluding document IDs tagged `download` or already handled during the session. Stop when no eligible `garimpo` items remain and summarize counts for Download, Delete, Next, and Listen.
