# YouTube transcripts

`assets/fetch_transcript.sh "<URL>"` handles the common case: it prefers human captions, falls back to auto-generated ones, and prints the title plus a `[MM:SS]`-stamped transcript. Use it directly.

The helper requires outbound HTTPS and DNS access to YouTube. In a network-restricted sandbox, request network permission and rerun it outside the sandbox. A message beginning with `Failed to fetch captions from YouTube` indicates an access or `yt-dlp` failure, not proof that captions are absent; use the included diagnostics before choosing a fallback.

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

Only when both caption checks complete successfully without producing a track does the script print `No transcript/captions available for this video.` Acquisition has failed: tell the user rather than distilling from the title or description. Options are to ask them for a transcript, or to transcribe the audio with a speech-to-text tool if one is available.

If the script instead prints `Failed to fetch captions from YouTube`, resolve the reported network, authentication, throttling, video-availability, or `yt-dlp` error and retry. Do not report that the video lacks captions based on a failed request.
