---
name: yt-channel-categorizer
description: Use when fetching, caching, categorizing, classifying, grouping, or labeling YouTube channel IDs, including requests to fetch channel metadata, cache channel IDs, look up channels, add channels to categories, or produce YouTube subscription category JSON.
---

# yt-channel-categorizer

Two commands:

1. **`fetch`** — pull channel metadata from YouTube into the local cache.
2. **`categorize`** — ensure all IDs are cached (calling `fetch` internally for
   any misses), then assign channels to categories and write a new
   `categories_*.json` file.

`fetch` never categorizes. `categorize` always ensures the cache is warm before
proceeding — it never fails due to missing metadata.

---

## Command: `fetch`

**Trigger:** the user asks to fetch, update, or pre-load metadata for a list of
channel IDs, without necessarily categorizing them yet.

**Input:** one or more channel IDs (`UC…`).

**Output:** an updated `channels_cache.json`.

### What the cache looks like

`channels_cache.json` lives in the agent's current working directory (i.e. the directory the agent is currently in when the command is invoked). It is a flat JSON
object mapping channel ID → metadata entry:

```json
{
  "UCYO_jab_esuFRV4b17AJtAw": {
    "id": "UCYO_jab_esuFRV4b17AJtAw",
    "title": "3Blue1Brown",
    "description": "Mathematics and entertainment...",
    "tags": ["math", "education"],
    "channel_follower_count": 6000000,
    "uploader_id": "@3blue1brown",
    "cached_at": "2026-05-11T18:58:33.000Z"
  }
}
```

Entry fields:

- `id` _(required)_ — the channel ID.
- `title` _(required)_ — from `.title // .channel // .uploader`.
- `description` _(required)_ — from `.description // ""`.
- `tags` _(optional)_ — from `.tags` if present, else omit.
- `channel_follower_count` _(optional)_ — from `.channel_follower_count` if
  present, else omit.
- `uploader_id` _(optional)_ — from `.uploader_id` if present, else omit.
- `cached_at` _(required)_ — ISO 8601 UTC timestamp of when the entry was
  written.

Cache invariants:

- **Entries are permanent.** No TTL. Remove stale entries by deleting the file
  or removing specific keys by hand.
- **Fetch failures are NOT cached.** Only successful `yt-dlp` responses produce
  an entry, so transient failures are retried on the next run.
- **Writes are atomic.** Always write to a `.tmp` file then `mv` into place.
- If the file does not exist, treat it as `{}` and bootstrap it.

### Using `assets/fetch_channels.sh`

The [`assets/fetch_channels.sh`](./assets/fetch_channels.sh) script implements
the full fetch workflow. Use it directly instead of running the steps manually.

```bash
# Pass IDs as arguments
./assets/fetch_channels.sh UCxxxxx UCyyyyy UCzzzzz

# Or from stdin (whitespace- or newline-separated)
echo "UCxxxxx UCyyyyy" | ./assets/fetch_channels.sh
./assets/fetch_channels.sh < ids.txt
```

Environment variables:

| Variable      | Default                 | Description                       |
| ------------- | ----------------------- | --------------------------------- |
| `CACHE_FILE`  | `./channels_cache.json` | Path to the cache file            |
| `PARALLELISM` | `8`                     | Max concurrent `yt-dlp` processes |

Exit codes:

- `0` — all IDs are now in the cache (hits + successful fetches).
- `1` — one or more IDs failed; listed on stderr; will be retried next run.

### Manual fetch steps (reference)

Use these if you need to understand or adapt the script's logic.

#### Step F1 — Load or bootstrap the cache

```bash
CACHE_FILE="./channels_cache.json"
[ -f "$CACHE_FILE" ] || echo '{}' > "$CACHE_FILE"
jq empty "$CACHE_FILE"   # abort immediately if the file is corrupted
```

#### Step F2 — Partition IDs into hits and misses

```bash
jq -e --arg id "<channel_id>" 'has($id)' "$CACHE_FILE" >/dev/null
```

- **Hit** (exit 0): entry already in cache — skip the network call.
- **Miss** (exit 1): add to the fetch list.

#### Step F3 — Fetch misses via `yt-dlp`

Run in parallel (background jobs or `xargs -P`):

```bash
yt-dlp --skip-download --playlist-items 0 --dump-single-json \
  "https://www.youtube.com/channel/<id>" 2>/dev/null \
  | jq --arg id "<id>" --arg now "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" '{
      id: $id,
      title: (.title // .channel // .uploader // ""),
      description: (.description // ""),
      tags: (.tags // empty),
      channel_follower_count: (.channel_follower_count // empty),
      uploader_id: (.uploader_id // empty),
      cached_at: $now
    }'
```

If `yt-dlp` exits non-zero or the output has no `title`, record as a failure —
do not write to the cache.

#### Step F4 — Merge successful entries into the cache atomically

```bash
jq --argjson new "$NEW_ENTRIES" '. += $new' "$CACHE_FILE" \
  > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"
```

### Fetch report

After the script (or manual steps) completes, print:

- **Cache:** `<hit_count> hits, <fetched_count> fetched, <fail_count> failed`
- **Fetch failures:** list any IDs that could not be resolved.

---

## Command: `categorize`

**Trigger:** the user asks to categorize, classify, or assign a list of channel
IDs to topic categories.

**Precondition:** all input IDs should be present in `channels_cache.json` before
classification. If any are missing, run the `fetch` command for those IDs first.
Only proceed with IDs that are present in the cache after that fetch step.

**Input:** one or more channel IDs (`UC…`).

**Output:** a new `categories_<timestamp>.json` file conforming to the
`YscData` schema.

### Output schema

The output file MUST conform to the `YscData` schema defined in
[`assets/categories_openapi_schema.json`](./assets/categories_openapi_schema.json).
Read that file before producing any output. The schema is the source of truth.

Key invariants:

- Fixed top-level keys: `ysc_collection`, `ysc_deck`, `ysc_meta`, `ysc_popup`,
  `ysc_settings`.
- Every other top-level key is a **dynamic category name** whose value is an
  array of channel IDs (each matching `^UC[A-Za-z0-9_-]{22}$`).
- `set(dynamic root keys) == set(ysc_collection keys) == set(ysc_meta keys)`.
  Adding or removing a category means updating all three places in lockstep.
- `ysc_settings` must retain its required fields: `install_date`, `lang`, `uid`.

### Step C1 — Ensure cache coverage

For each input ID, check whether it exists in `channels_cache.json`:

```bash
jq -e --arg id "<channel_id>" 'has($id)' channels_cache.json >/dev/null
```

For any IDs that are missing, run the `fetch` command on them before
continuing. Only proceed to Step C2 once every input ID is present in the
cache. If fetch fails for some IDs, exclude them from categorization and list
them under **Fetch failures** in the report.

### Step C2 — Read the latest categories file

```bash
ls -1 ./categories_*.json 2>/dev/null | sort | tail -1
```

Read the file. If none exists, bootstrap a minimal valid `YscData`:

- `ysc_collection`, `ysc_meta`, `ysc_popup` → `{}`
- `ysc_deck` → `[]`
- `ysc_settings` → `{ "install_date": <current Unix ms>, "lang": "en", "uid": "<short hex string>" }`
  Ask the user for these values if you cannot reasonably infer them.

### Step C3 — Derive categories

With all channel titles and descriptions in front of you, invent a minimal,
meaningful set of category labels for the full input set.

Guidelines:

- Lowercase, 1–3 words.
- Let the channels themselves suggest the groupings — do not use a preset list.
- **Prefer generic over specific.** A broad bucket that holds several channels
  is more useful than a narrow one that holds one. Stretch a label one level
  broader before committing (e.g. `machine learning` → `ai` → `tech`).
- Avoid labels so generic they describe all of YouTube (`content`,
  `entertainment`, `media`). The sweet spot is broad enough that channels stack
  up, specific enough that the label is still informative.
- Aim for mutual exclusivity: each channel should sit clearly in one category.

### Step C4 — Cross-examine with existing categories

For each newly derived label, compare against the keys of `ysc_collection`:

- **Exact match** → reuse as-is.
- **Semantically overlapping or a subtopic** → fold into the existing broader
  name (e.g. derived `physics` + existing `science` → use `science`; derived
  `kpop` + existing `music` → use `music`).
- **Genuinely new concept** with no close existing match → add as a new
  category. Only add a new key when the concept does not meaningfully belong
  under anything already there.

Goal: a coherent, non-redundant taxonomy that grows sensibly over time.

### Step C5 — Assign channels and sync metadata

Place each input channel ID into exactly one best-fit category. Never move,
remove, or modify existing channel ID assignments.

When creating a **new** category, update all three locations atomically:

1. Root: `"<cat>": [<channel_ids>]`
2. `ysc_collection`: `"<cat>": "<cat>"`
3. `ysc_meta`: `"<cat>": { "img": "/icon/new_pack/_52.png" }`

When adding to an **existing** category, only the root array changes.

If a channel is genuinely ambiguous between two categories, pick the closer fit
and flag it in the report.

### Step C6 — Write output file

```
./categories_<UTC-ISO-8601-timestamp>.json
```

Example: `categories_2026-05-11T14:30:00.000Z.json`

Carry over every fixed key and every existing dynamic category unchanged.
Append new channel IDs to their category arrays. Add new category keys at the
root, in `ysc_collection`, and in `ysc_meta`.

### Step C6.5 — Validate

Before reporting, verify:

1. Every channel ID matches `^UC[A-Za-z0-9_-]{22}$`.
2. `set(dynamic root keys) == set(ysc_collection keys) == set(ysc_meta keys)`.
3. `ysc_settings` contains `install_date`, `lang`, and `uid`.
4. Every `ysc_meta[*]` entry has a non-empty `img` string.
5. No existing channel ID was removed or moved between categories.

Fix any violation before writing the file. Do not emit a non-compliant file.

### Categorize report

Print a concise summary:

- **File written:** the new filename.
- **Cache:** `<hit_count> hits, <fetched_count> fetched, <fail_count> failed`
  (from the implicit fetch step; omit if all IDs were already cached).
- **Added to existing categories:** `<channel name>` → `<category>`
- **New categories created:** `<category>` containing `<channel names>`
- **Ambiguous assignments:** channel name, the two competing categories, and
  the reasoning for the choice made.
- **Fetch failures:** IDs that could not be fetched and were excluded.
