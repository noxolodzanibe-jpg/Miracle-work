#!/usr/bin/env bash
# Installs the video toolkit: FFmpeg (cut + mix video), HyperFrames (captions +
# graphics), and yt-dlp (save Reels). Works on macOS (Homebrew) and Debian/Ubuntu.
set -euo pipefail

have() { command -v "$1" >/dev/null 2>&1; }

if [[ "$(uname)" == "Darwin" ]]; then
  have brew || { echo "Install Homebrew first: https://brew.sh"; exit 1; }
  have ffmpeg || brew install ffmpeg
  have yt-dlp || brew install yt-dlp
  have node   || brew install node
else
  SUDO=""; [[ $EUID -ne 0 ]] && SUDO="sudo"
  have ffmpeg || { $SUDO apt-get update && $SUDO apt-get install -y ffmpeg; }
  have yt-dlp || python3 -m pip install -U yt-dlp
  have node   || { echo "Install Node.js 22+: https://nodejs.org"; exit 1; }
fi

have hyperframes || npm install -g hyperframes

echo
ffmpeg -version | head -1
echo "yt-dlp $(yt-dlp --version)"
echo "hyperframes $(hyperframes --version)"
