#!/usr/bin/env bash
# Amelix CLI launcher — run this from anywhere. It resolves ITS OWN folder,
# sets up/activates the environment, and drops you into a shell with the
# `amelix` command ready (e.g. amelix scan-url "...").
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f "venv/bin/python" ]; then
    echo "[Amelix] No virtual environment found — setting one up the first time..."
    if ! command -v python3 >/dev/null 2>&1; then
        echo "[Amelix] ERROR: python3 isn't installed. Install it with your package manager and try again."
        exit 1
    fi
    python3 -m venv venv --system-site-packages || python3 -m venv venv
fi

echo "[Amelix] Checking / installing dependencies (fast if already up to date)..."
"venv/bin/python" -m pip install -q --upgrade pip
"venv/bin/python" -m pip install -q -e .

echo
echo "[Amelix] Ready. Try:  amelix scan-url \"http://example.com\""
echo "[Amelix] Or:          amelix-gui"
echo
source venv/bin/activate
exec "${SHELL:-/bin/bash}"
