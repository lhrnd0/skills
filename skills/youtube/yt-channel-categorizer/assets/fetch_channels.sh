#!/usr/bin/env bash
# fetch_channels.sh — Fetch YouTube channel metadata via yt-dlp, with cache.
#
# Usage:
#   fetch_channels.sh <channel_id> [<channel_id> ...]
#   echo "UCxxx UCyyy" | fetch_channels.sh
#   fetch_channels.sh < ids.txt
#
# Each argument or whitespace-separated token on stdin is treated as a channel ID.
# IDs already present in the cache are skipped (no network call).
# Successful fetches are merged into the cache atomically.
#
# Environment:
#   CACHE_FILE   Path to the JSON cache file.
#                Default: <script-dir>/../channels_cache.json
#   PARALLELISM  Max concurrent yt-dlp processes. Default: 8
#
# Exit codes:
#   0  All requested channels are now in the cache (hits + successful fetches).
#   1  One or more channels failed to fetch (reported to stderr; cache unchanged
#      for those IDs so they will be retried next run).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_FILE="${CACHE_FILE:-"$SCRIPT_DIR/../channels_cache.json"}"
PARALLELISM="${PARALLELISM:-8}"

# ── helpers ──────────────────────────────────────────────────────────────────

die() { echo "ERROR: $*" >&2; exit 1; }

# ── Step 1a: load / bootstrap cache ──────────────────────────────────────────

if [ ! -f "$CACHE_FILE" ]; then
  echo '{}' > "$CACHE_FILE"
  echo "Bootstrapped empty cache at $CACHE_FILE" >&2
fi

jq empty "$CACHE_FILE" 2>/dev/null \
  || die "Cache file is corrupted: $CACHE_FILE  — inspect or delete it and retry."

# ── Collect input IDs ─────────────────────────────────────────────────────────

ALL_IDS=()

# From positional arguments
for arg in "$@"; do
  for token in $arg; do
    ALL_IDS+=("$token")
  done
done

# From stdin (only if no args, or stdin is not a terminal)
if [ "${#ALL_IDS[@]}" -eq 0 ] || ! [ -t 0 ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    for token in $line; do
      ALL_IDS+=("$token")
    done
  done
fi

if [ "${#ALL_IDS[@]}" -eq 0 ]; then
  echo "Usage: fetch_channels.sh <channel_id> [<channel_id> ...]" >&2
  exit 1
fi

# Deduplicate while preserving order (portable — no bash 4 associative arrays)
UNIQUE_IDS=()
for id in "${ALL_IDS[@]}"; do
  already=0
  for seen in "${UNIQUE_IDS[@]+"${UNIQUE_IDS[@]}"}"; do
    [ "$seen" = "$id" ] && already=1 && break
  done
  [ "$already" -eq 0 ] && UNIQUE_IDS+=("$id")
done

# ── Step 1b: partition into hits / misses ─────────────────────────────────────

HITS=()
MISSES=()
for id in "${UNIQUE_IDS[@]}"; do
  if jq -e --arg id "$id" 'has($id)' "$CACHE_FILE" >/dev/null 2>&1; then
    HITS+=("$id")
  else
    MISSES+=("$id")
  fi
done

echo "Cache: ${#HITS[@]} hit(s), ${#MISSES[@]} to fetch" >&2

if [ "${#MISSES[@]}" -eq 0 ]; then
  echo "All channels already cached." >&2
  exit 0
fi

# ── Step 1c: fetch misses in parallel ─────────────────────────────────────────

TMPDIR_FETCH="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_FETCH"' EXIT

fetch_one() {
  local id="$1"
  local out="$TMPDIR_FETCH/${id}.json"
  local now
  now=$(date -u +%Y-%m-%dT%H:%M:%S.000Z)

  yt-dlp \
    --skip-download \
    --playlist-items 0 \
    --dump-single-json \
    "https://www.youtube.com/channel/${id}" \
    2>/dev/null \
  | jq --arg id "$id" --arg now "$now" '{
      id: $id,
      title: (.title // .channel // .uploader // ""),
      description: (.description // ""),
      tags: (.tags // empty),
      channel_follower_count: (.channel_follower_count // empty),
      uploader_id: (.uploader_id // empty),
      cached_at: $now
    }' > "$out" 2>/dev/null

  if [ -s "$out" ] && jq -e '.title and (.title != "")' "$out" >/dev/null 2>&1; then
    echo "OK: $id" >&2
  else
    rm -f "$out"
    echo "FAIL: $id" >&2
  fi
}

export -f fetch_one
export TMPDIR_FETCH

# Run up to $PARALLELISM jobs concurrently using a job-slot semaphore
active=0
for id in "${MISSES[@]}"; do
  fetch_one "$id" &
  (( active++ ))
  if [ "$active" -ge "$PARALLELISM" ]; then
    wait -n 2>/dev/null || wait   # wait for any one job to finish
    (( active-- ))
  fi
done
wait

# ── Step 1d: merge successful fetches into cache atomically ───────────────────

SUCCESS_FILES=("$TMPDIR_FETCH"/*.json)
FAIL_COUNT=0
FETCH_COUNT=0

if compgen -G "$TMPDIR_FETCH/*.json" >/dev/null 2>&1; then
  NEW_ENTRIES=$(jq -s 'map({(.id): .}) | add' "$TMPDIR_FETCH"/*.json)
  FETCH_COUNT=$(echo "$NEW_ENTRIES" | jq 'keys | length')

  jq --argjson new "$NEW_ENTRIES" '. += $new' "$CACHE_FILE" \
    > "$CACHE_FILE.tmp" \
    && mv "$CACHE_FILE.tmp" "$CACHE_FILE"

  echo "Merged $FETCH_COUNT new entry/entries into cache." >&2
fi

FAIL_COUNT=$(( ${#MISSES[@]} - FETCH_COUNT ))

if [ "$FAIL_COUNT" -gt 0 ]; then
  echo "WARNING: $FAIL_COUNT channel(s) failed to fetch and were NOT cached." >&2
  # List which ones failed
  for id in "${MISSES[@]}"; do
    [ ! -f "$TMPDIR_FETCH/${id}.json" ] && echo "  FAIL: $id" >&2
  done
  exit 1
fi

echo "Done. Cache now contains $(jq 'keys | length' "$CACHE_FILE") entries." >&2
