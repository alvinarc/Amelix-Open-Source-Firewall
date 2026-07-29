@echo off
REM Amelix GUI launcher — double-click this from anywhere (Desktop, Start Menu
REM shortcut, another drive, etc.). It always finds ITS OWN folder first,
REM so it never depends on what directory you launched it from.

setlocal
cd /d "%~dp0"

if not exist "venv\Scripts\python.exe" (
    echo [Amelix] No virtual environment found — setting one up the first time...
    python -m venv venv
    if errorlevel 1 (
        echo [Amelix] ERROR: Python isn't installed or isn't on PATH. Install it from python.org and try again.
        pause
        exit /b 1
    )
)

echo [Amelix] Checking / installing dependencies (fast if already up to date)...
"venv\Scripts\python.exe" -m pip install -q --upgrade pip
"venv\Scripts\python.exe" -m pip install -q -e .

echo [Amelix] Launching GUI...
"venv\Scripts\python.exe" -m amelix.gui

if errorlevel 1 (
    echo.
    echo [Amelix] Something went wrong — see the error above.
    pause
)
