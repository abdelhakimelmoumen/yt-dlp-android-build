#!/usr/bin/env bash
set -euo pipefail

mkdir -p dist work/payload
cp -r work/pkgroot/usr work/payload/usr
cp work/yt-dlp.pyz work/payload/yt-dlp.pyz

tar -C work/payload -czf work/payload.tar.gz .

cat launcher/launcher_template.sh > dist/yt-dlp
base64 work/payload.tar.gz >> dist/yt-dlp
chmod +x dist/yt-dlp

echo "Final single-file executable created at dist/yt-dlp"
ls -lh dist/yt-dlp
