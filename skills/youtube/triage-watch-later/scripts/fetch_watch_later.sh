#!/usr/bin/env bash
# Print the authenticated YouTube Watch Later queue as normalized JSON.
# Usage: YOUTUBE_BROWSER=chrome ./fetch_watch_later.sh
#    or: YOUTUBE_COOKIES_FILE=/path/to/cookies.txt ./fetch_watch_later.sh
set -euo pipefail

command -v yt-dlp >/dev/null || {
  echo "yt-dlp not found: install it before fetching Watch Later" >&2
  exit 127
}
command -v jq >/dev/null || {
  echo "jq not found: install it before fetching Watch Later" >&2
  exit 127
}

browser="${1:-${YOUTUBE_BROWSER:-}}"
cookie_file="${YOUTUBE_COOKIES_FILE:-}"
cookie_args=()

if [[ -n "$cookie_file" ]]; then
  [[ -r "$cookie_file" ]] || {
    echo "YOUTUBE_COOKIES_FILE is not readable: $cookie_file" >&2
    exit 2
  }
  cookie_args=(--cookies "$cookie_file")
elif [[ -n "$browser" ]]; then
  cookie_args=(--cookies-from-browser "$browser")
else
  echo "Set YOUTUBE_COOKIES_FILE or YOUTUBE_BROWSER (for example: chrome, firefox, or safari)." >&2
  exit 2
fi

yt-dlp \
  --ignore-config \
  --flat-playlist \
  --dump-single-json \
  "${cookie_args[@]}" \
  :ytwatchlater |
  jq '
    [(.entries // []) | to_entries[]
      | select(.value.id != null)
      | {
          position: (.value.playlist_index // (.key + 1)),
          id: .value.id,
          title: (.value.title // ""),
          channel: (.value.channel // .value.uploader // ""),
          duration: .value.duration,
          url: ("https://www.youtube.com/watch?v=" + .value.id)
        }
    ] as $videos
    | {
        fetched_at: (now | todateiso8601),
        count: ($videos | length),
        videos: $videos
      }
  '
