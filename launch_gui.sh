#!/usr/bin/env bash
# Amelix GUI launcher — run this from anywhere (any working directory, any
# shell). It always resolves ITS OWN folder first via $0, so it never
# depends on where you called it from.
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

if ! "venv/bin/python" -c "import tkinter" 2>/dev/null; then
    echo "[Amelix] WARNING: tkinter isn't available in this environment."
    echo "         Install it with: sudo apt install python3-tk   (Debian/Ubuntu)"
    echo "                          sudo dnf install python3-tkinter  (Fedora)"
    echo "         then delete the venv/ folder and run this script again."
    exit 1
fi

echo "[Amelix] Launching GUI..."
exec "venv/bin/python" -m amelix.gui
