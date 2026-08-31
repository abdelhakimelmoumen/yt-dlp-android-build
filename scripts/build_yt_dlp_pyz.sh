#!/usr/bin/env bash
set -euo pipefail

python3 -m venv work/venv
source work/venv/bin/activate
pip install -U pip yt-dlp

# Build the zipapp from the installed package
python3 -m zipapp \
  "$(python3 -c 'import yt_dlp, os; print(os.path.dirname(yt_dlp.__file__))')" \
  -m "yt_dlp.__main__:main" \
  -o work/yt-dlp.pyz \
  -c

deactivate
echo "Built work/yt-dlp.pyz"
