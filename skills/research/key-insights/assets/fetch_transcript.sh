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
  unset SSLKEYLOGFILE
  yt-dlp --skip-download "$1" \
    --sub-langs "$sub_langs" --sub-format vtt \
    -o "$workdir/sub.%(ext)s" "$URL" >/dev/null 2>&1 || true
}

# Human captions first, then auto-generated.
fetch --write-subs
vtt="$(ls "$workdir"/*.vtt 2>/dev/null | head -1 || true)"
if [ -z "$vtt" ]; then
  fetch --write-auto-subs
  vtt="$(ls "$workdir"/*.vtt 2>/dev/null | head -1 || true)"
fi

if [ -z "$vtt" ]; then
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
