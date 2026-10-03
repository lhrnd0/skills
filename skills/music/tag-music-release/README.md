# tag-music-release

Guide a Rekordbox star rating and set-phase, mood, vibe, and instrument tags into a release or track, so Rekordbox search finds tracks by feel. It can also override `GENRE` and `STYLE`. Edit the tag words in [`references/vocabulary.md`](./references/vocabulary.md).

The skill writes stars to the MP3 `POPM` frame, the FLAC `RATING` field (0–100), and a `Rating:<stars>` comment token. Rekordbox shows stars only from MP3 files; for other formats, the skill lists the stars to set in Rekordbox.

## Requirements

```sh
brew install flac ffmpeg uv
```
