#!/usr/bin/env bash
# Fetch a YouTube transcript as timestamped plain text.
# Usage: ./fetch_transcript.sh "<youtube-url-or-id>" [lang]
# Prints "# <title>" then a [MM:SS]-stamped transcript on stdout.
# Prefers human captions, falls back to auto-generated ones.
set -euo pipefail

URL="${1:?usage: fetch_transcript.sh <youtube-url-or-id> [lang]}"
LANG_PREF="${2:-en}"

command -v yt-dlp >/dev/null || { echo "yt-dlp not found: brew install yt-dlp" >&2; exit 127; }

workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT

sub_langs="${LANG_PREF},${LANG_PREF}.*,${LANG_PREF}-orig,en,en.*"

fetch() {
  local mode="$1"
  local log="$2"
  unset SSLKEYLOGFILE
  yt-dlp --skip-download "$mode" \
    --sub-langs "$sub_langs" --sub-format vtt \
    -o "$workdir/sub.%(ext)s" "$URL" >"$log" 2>&1
}

report_fetch_error() {
  local log="$1"
  echo "Failed to fetch captions from YouTube." >&2
  if grep -Eqi 'failed to resolve|name resolution|network is unreachable|connection (refused|reset)|timed out|unable to download' "$log"; then
    echo "Network access failed. Allow outbound HTTPS/DNS access (or rerun with elevated network permission), then retry." >&2
  fi
  echo "yt-dlp diagnostics:" >&2
  tail -20 "$log" >&2
}

# Human captions first, then auto-generated.
human_log="$workdir/human.log"
auto_log="$workdir/auto.log"
human_status=0
fetch --write-subs "$human_log" || human_status=$?
vtt="$(ls "$workdir"/*.vtt 2>/dev/null | head -1 || true)"
if [ -z "$vtt" ]; then
  auto_status=0
  fetch --write-auto-subs "$auto_log" || auto_status=$?
  vtt="$(ls "$workdir"/*.vtt 2>/dev/null | head -1 || true)"
fi

if [ -z "$vtt" ]; then
  if [ "${auto_status:-0}" -ne 0 ]; then
    report_fetch_error "$auto_log"
    exit "$auto_status"
  fi
  if [ "$human_status" -ne 0 ]; then
    report_fetch_error "$human_log"
    exit "$human_status"
  fi
  echo "No transcript/captions available for this video." >&2
  exit 1
fi

title="$(yt-dlp --skip-download --print "%(title)s" "$URL" 2>/dev/null || true)"
[ -n "$title" ] && printf '# %s\n\n' "$title"

# VTT -> [MM:SS] plain text: strip inline tags, dedupe rolling auto-caption
# repeats, and emit one stamped line roughly every GAP seconds.
awk '
  BEGIN { gap=15; last_stamp=-99999; buf=""; stamp=""; }
  function secs(t,  a){ split(t, a, ":"); return a[1]*3600 + a[2]*60 + int(a[3]); }
  function fmt(s,  m){ m=int(s/60); s=s%60; return sprintf("[%02d:%02d]", m, s); }
  function flush(){ if (buf != "") { print stamp, buf; buf=""; } }
  /-->/ { cur=secs($1); next }
  /^WEBVTT/ || /^Kind:/ || /^Language:/ || /^NOTE/ { next }
  /^[[:space:]]*$/ { next }
  {
    line=$0;
    gsub(/<[^>]*>/, "", line);
    gsub(/^[ \t]+|[ \t]+$/, "", line);
    if (line == "" || line == last) next;
    last=line;
    if (cur - last_stamp >= gap) { flush(); stamp=fmt(cur); last_stamp=cur; }
    buf = (buf == "" ? line : buf " " line);
  }
  END { flush(); }
' "$vtt"
