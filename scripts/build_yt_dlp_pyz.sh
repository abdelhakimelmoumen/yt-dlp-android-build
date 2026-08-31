#!/usr/bin/env bash
set -euo pipefail

python3 -m venv work/venv
source work/venv/bin/activate
pip install -U pip yt-dlp

# Build the zipapp from the installed package.
# yt_dlp already ships its own __main__.py, so zipapp uses that as the entry
# point automatically -- passing -m as well is rejected as a conflict.
python3 -m zipapp \
  "$(python3 -c 'import yt_dlp, os; print(os.path.dirname(yt_dlp.__file__))')" \
  -o work/yt-dlp.pyz \
  -c

deactivate
echo "Built work/yt-dlp.pyz"
