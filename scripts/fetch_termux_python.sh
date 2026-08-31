#!/usr/bin/env bash
# Fallback / manual method for fetching a prebuilt Termux (Android arm64) Python.
# The workflow.yml uses the Docker-based method by default (more reliable,
# handles dependency resolution automatically). Use this script only if you
# cannot use Docker in your CI environment.
set -euo pipefail
mkdir -p work/pkgroot
cd work

REPO="https://packages.termux.dev/apt/termux-main/pool/main/p/python"

# Pin exact versions after checking the repo listing — versions change often.
PY_DEB_URL="$(curl -s "$REPO/" | grep -oE 'python_[0-9.\-]+_aarch64\.deb' | sort -V | tail -1)"
curl -LO "$REPO/${PY_DEB_URL}"

# .deb is an ar archive containing data.tar.xz
ar x "${PY_DEB_URL}"
mkdir -p extracted
tar -xf data.tar.* -C extracted

# Termux installs under /data/data/com.termux/files, mirror that layout
mkdir -p pkgroot
cp -r extracted/data/data/com.termux/files/usr pkgroot/usr

echo "NOTE: this script does not resolve runtime dependencies"
echo "(libcrypt, openssl, sqlite, ncurses, readline, libffi, libc++)."
echo "You must fetch and merge those .deb packages the same way, or"
echo "prefer the Docker-based step in .github/workflows/build.yml instead."
echo "Python staged in work/pkgroot/usr"
