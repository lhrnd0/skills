# YouTube transcripts

`assets/fetch_transcript.sh "<URL>"` handles the common case: it prefers human captions, falls back to auto-generated ones, and prints the title plus a `[MM:SS]`-stamped transcript. Use it directly.

## Manual fetch (for adapting or debugging)

List the available caption tracks:

```
yt-dlp --list-subs "<URL>"
```

Download a track as VTT (human captions, then auto-generated):

```
yt-dlp --skip-download --write-subs      --sub-langs en --sub-format vtt -o sub "<URL>"
yt-dlp --skip-download --write-auto-subs --sub-langs en --sub-format vtt -o sub "<URL>"
```

Auto-caption VTT repeats each line as the caption rolls and embeds inline `<timestamp><c>` tags. Strip the tags (`<[^>]*>`) and dedupe consecutive lines to get clean text — this is what the script does.

## When there are no captions

If neither human nor auto captions exist, the script exits non-zero and prints "No transcript/captions available." Acquisition has failed: tell the user rather than distilling from the title or description. Options are to ask them for a transcript, or to transcribe the audio with a speech-to-text tool if one is available.
