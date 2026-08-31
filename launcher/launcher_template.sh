#!/system/bin/sh
# Self-extracting launcher. Payload appended below as base64 tar.gz.
set -e
APPDIR="${YTDLP_HOME:-$(dirname "$0")/.ytdlp_runtime}"

if [ ! -f "$APPDIR/.extracted" ]; then
  mkdir -p "$APPDIR"
  SELF="$0"
  MARKER=$(awk '/^__PAYLOAD_BELOW__/ {print NR + 1; exit 0; }' "$SELF")
  tail -n +"$MARKER" "$SELF" | base64 -d | tar -xz -C "$APPDIR"
  chmod +x "$APPDIR/usr/bin/python3"
  touch "$APPDIR/.extracted"
fi

export LD_LIBRARY_PATH="$APPDIR/usr/lib"
exec "$APPDIR/usr/bin/python3" "$APPDIR/yt-dlp.pyz" "$@"
exit 0
__PAYLOAD_BELOW__
