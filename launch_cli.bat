@echo off
REM Amelix CLI launcher — double-click this from anywhere. It finds ITS OWN
REM folder, sets up/activates the environment, and drops you into a prompt
REM with the `amelix` command ready to use (e.g. amelix scan-url "...").

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

echo.
echo [Amelix] Ready. Try:  amelix scan-url "http://example.com"
echo [Amelix] Or:          amelix-gui
echo.
cmd /k "venv\Scripts\activate.bat"
