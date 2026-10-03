#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["mutagen"]
# ///
"""Read or write the MP3 comment, Rekordbox star rating, and genre.

Rekordbox reads stars from the ID3 POPM frame by byte range; the bytes below
are verified against rekordbox 7.2.16.

  mp3-tags.py read <file>
  mp3-tags.py write <file> --comment <text> --stars <0-5> [--genre <text>]

--genre writes the same text to TCON and TXXX:STYLE, per the format-music-release
archive rules; without it, both stay untouched.
"""

import argparse
import json

from mutagen.id3 import COMM, ID3, POPM, TCON, TXXX, ID3NoHeaderError

STAR_BYTES = {1: 1, 2: 64, 3: 128, 4: 196, 5: 255}
POPM_EMAIL = "Windows Media Player 9 Series"


def stars_from_byte(value):
    return max((s for s, b in STAR_BYTES.items() if value >= b), default=0)


def load(path):
    try:
        return ID3(path)
    except ID3NoHeaderError:
        return ID3()


def comment_frames(tags):
    # Description-less COMM is the comment Rekordbox reads; ffmpeg writes TXXX:comment instead.
    # COMM frames with a description, such as iTunNORM, are other data.
    return [f for f in tags.getall("COMM") if f.desc == ""] + [
        f for f in tags.getall("TXXX") if f.desc.lower() == "comment"
    ]


def read(path):
    tags = load(path)
    comments = [{"frame": f.HashKey, "text": str(t)} for f in comment_frames(tags) for t in f.text]
    ratings = [{"email": p.email, "byte": p.rating, "stars": stars_from_byte(p.rating)} for p in tags.getall("POPM")]
    genre = [str(t) for f in tags.getall("TCON") for t in f.text]
    style = [str(t) for f in tags.getall("TXXX:STYLE") for t in f.text]
    print(json.dumps({"comments": comments, "ratings": ratings, "genre": genre, "style": style}, ensure_ascii=False))


def write(path, comment, stars, genre=None):
    tags = load(path)
    for frame in comment_frames(tags):
        tags.delall(frame.HashKey)
    tags.add(COMM(encoding=3, lang="eng", desc="", text=comment))
    tags.delall("POPM")
    if stars:
        tags.add(POPM(email=POPM_EMAIL, rating=STAR_BYTES[stars], count=0))
    if genre is not None:
        tags.delall("TCON")
        tags.delall("TXXX:STYLE")
        tags.add(TCON(encoding=3, text=genre))
        tags.add(TXXX(encoding=3, desc="STYLE", text=genre))
    tags.save(path)


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("read").add_argument("file")
    w = sub.add_parser("write")
    w.add_argument("file")
    w.add_argument("--comment", required=True)
    w.add_argument("--stars", type=int, choices=range(6), required=True)
    w.add_argument("--genre")
    args = parser.parse_args()
    if args.command == "read":
        read(args.file)
    else:
        write(args.file, args.comment, args.stars, args.genre)


if __name__ == "__main__":
    main()
