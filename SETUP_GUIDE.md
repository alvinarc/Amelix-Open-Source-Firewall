# Amelix — Step-by-Step Setup Guide (Windows & Linux)

This file walks through getting Amelix running from a completely fresh
machine, step by step, with nothing assumed. Follow the section for your OS.

---

## 0. Before you start

You need:
- Python 3.10 or newer
- The `amelix` folder from the zip you downloaded, extracted somewhere
  convenient (e.g. `C:\amelix` on Windows or `~/amelix` on Linux)
- (Optional but recommended) A free VirusTotal API key and/or AbuseIPDB
  API key, if you want live threat-intelligence lookups instead of local-only
  heuristics:
  - VirusTotal: https://www.virustotal.com/gui/join-us → Profile → API Key
  - AbuseIPDB: https://www.abuseipdb.com/register → Account → API

Without keys, everything still runs — phishing ML scoring, SMS scam
detection, entropy/heuristic malware checks, network anomaly detection, and
the Zero Trust policy engine are all 100% local and don't need any key.
Only `check-ip`, `check-domain`, and the reputation-lookup part of
`scan-file`/`scan-url` need keys — they'll just report `"no_api_key"`
until you add one.

---

## 1. Windows — Step by Step

### Step 1.1 — Check Python is installed
Open **PowerShell** and run:
```powershell
python --version
```
If you see `Python 3.10` or higher, continue. If not, install Python from
https://www.python.org/downloads/ (check "Add Python to PATH" during install),
then reopen PowerShell and re-run the command above.

### Step 1.2 — Go to the project folder
```powershell
cd C:\path\to\amelix
```
(Replace with wherever you extracted the zip — the folder that contains
`README.md`, `pyproject.toml`, and the `amelix\` subfolder.)

### Step 1.3 — Create a virtual environment
```powershell
python -m venv venv
```

### Step 1.4 — Activate it
```powershell
venv\Scripts\Activate.ps1
```
If PowerShell blocks the script with an execution-policy error, run this once
(as your normal user, not admin) and try activating again:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```
You'll know it worked when your prompt shows `(venv)` at the start.

### Step 1.5 — Install dependencies
```powershell
pip install -r requirements.txt
pip install -e .
```

### Step 1.6 — Add your API keys
```powershell
copy .env.example .env
notepad .env
```
Fill in:
```
VIRUSTOTAL_API_KEY=your_key_here
ABUSEIPDB_API_KEY=your_key_here
```
Save and close Notepad.

### Step 1.7 — Train the models (one-time, ~2 seconds each)
```powershell
python -m amelix.cli train-phishing
python -m amelix.cli train-netmodel
```

### Step 1.8 — Run your first scans
```powershell
python -m amelix.cli scan-url "http://paypal-secure-login.verify-account.tk/reset"
python -m amelix.cli scan-sms "URGENT your account has been suspended, verify now: bit.ly/xyz"
python -m amelix.cli check-ip 8.8.8.8
python -m amelix.cli scan-file C:\path\to\some\file.exe
python -m amelix.cli policy-eval --user alice --role employee --resource employee-portal --device-health healthy
```

### Step 1.9 — Launch the GUI (recommended)
```powershell
python -m amelix.gui
```
A window titled "Amelix — AI Security Firewall" should open with tabs for
each module. If it doesn't, make sure you activated the venv (Step 1.4) and
see the Troubleshooting section below.

You're done — jump to **Section 3: Full Command Reference** or
**Section 4: Using the GUI** below.

---

## 2. Linux — Step by Step

### Step 2.1 — Check Python is installed
```bash
python3 --version
```
Need 3.10+. If missing or too old:
```bash
sudo apt update && sudo apt install python3 python3-venv python3-pip
```
(use your distro's package manager if not Debian/Ubuntu-based)

### Step 2.2 — Go to the project folder
```bash
cd ~/amelix
```
(wherever you extracted the zip)

### Step 2.3 — Create a virtual environment
```bash
python3 -m venv venv
```

### Step 2.4 — Activate it
```bash
source venv/bin/activate
```
Your prompt should now show `(venv)` at the start.

### Step 2.5 — Install dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
pip install -e .
```

### Step 2.6 — Add your API keys
```bash
cp .env.example .env
nano .env
```
Fill in:
```
VIRUSTOTAL_API_KEY=your_key_here
ABUSEIPDB_API_KEY=your_key_here
```
Save with `Ctrl+O`, `Enter`, then exit with `Ctrl+X`.

### Step 2.7 — Train the models (one-time, ~2 seconds each)
```bash
python -m amelix.cli train-phishing
python -m amelix.cli train-netmodel
```

### Step 2.8 — Run your first scans
```bash
python -m amelix.cli scan-url "http://paypal-secure-login.verify-account.tk/reset"
python -m amelix.cli scan-sms "URGENT your account has been suspended, verify now: bit.ly/xyz"
python -m amelix.cli check-ip 8.8.8.8
python -m amelix.cli scan-file /path/to/some/file
python -m amelix.cli policy-eval --user alice --role employee --resource employee-portal --device-health healthy
```

### Step 2.9 — Launch the GUI (recommended)
The GUI uses Tkinter, which is part of Python but is sometimes packaged
separately on Linux. If launching fails with `ModuleNotFoundError: No
module named 'tkinter'`, install it first:
```bash
sudo apt install python3-tk        # Debian/Ubuntu
sudo dnf install python3-tkinter   # Fedora
sudo pacman -S tk                  # Arch
```
Then launch:
```bash
python -m amelix.gui
```
A window titled "Amelix — AI Security Firewall" should open with tabs for
each module.

### Optional — run the test suite to confirm everything works
```bash
pip install pytest
pytest tests/ -v
```
You should see `9 passed`.

---

## 3. Full Command Reference

Run all of these from inside the activated virtual environment
(`(venv)` showing in your prompt), from the project's root folder.

| What you want to do | Command |
|---|---|
| Train the phishing model | `python -m amelix.cli train-phishing` |
| Check a URL | `python -m amelix.cli scan-url "<url>"` |
| Check an email file | `python -m amelix.cli scan-email samples/phish_sample.eml` |
| Check an SMS/message | `python -m amelix.cli scan-sms "<text>"` |
| Check a single file (hash/entropy/malware) | `python -m amelix.cli scan-file <path>` |
| Check every file in a folder | `python -m amelix.cli scan-dir <folder>` |
| Look up an IP's reputation | `python -m amelix.cli check-ip <ip>` |
| Look up a domain's reputation | `python -m amelix.cli check-domain <domain>` |
| Add something to your local blocklist | `python -m amelix.cli blocklist-add <ip/domain/hash>` |
| Train the network anomaly model | `python -m amelix.cli train-netmodel` |
| Score a netflow CSV for anomalies | `python -m amelix.cli scan-netflow <path.csv>` |
| Voice deepfake check (honest stub) | `python -m amelix.cli scan-audio <path>` |
| Image/video deepfake check (stub + forensics) | `python -m amelix.cli scan-media <path>` |
| Evaluate a Zero Trust access decision | `python -m amelix.cli policy-eval --user <name> --role <role> --resource <resource> --device-health <status>` |

Every command prints its result as readable JSON directly in your terminal.

---

## 4. Try the bundled samples

Two sample emails are included so you can see the phishing detector work
without needing your own test data:

```bash
python -m amelix.cli scan-email samples/phish_sample.eml   # should say "phishing"
python -m amelix.cli scan-email samples/legit_sample.eml    # should say "legit"
```

A sample netflow file is also included:
```bash
python -m amelix.cli scan-netflow data/sample_netflow.csv
```

---

## 4. Using the GUI

Launch with `python -m amelix.gui` (from the activated venv, either OS).
The window has one tab per module — everything the command line can do,
the GUI can do too:

| Tab | What it does |
|---|---|
| **Phishing / Email** | Type a URL and click "Scan URL", or load a `.eml`/text file and click to scan it. A colored badge shows the verdict (green=legit, yellow=suspicious, red=phishing) with the risk score. "Train / retrain phishing model" re-trains on `data/phishing_urls_sample.csv`. |
| **SMS / Scam** | Paste a text message and scan it for scam patterns, spoofed brand names, and malicious links. |
| **Malware / Files** | Scan a single file or an entire folder — shows SHA-256, entropy, VirusTotal reputation (if key set), and a verdict. |
| **Threat Intel** | Look up an IP (AbuseIPDB) or domain (VirusTotal), or add an indicator to your local blocklist. |
| **Network Anomaly** | Train the anomaly model or load/score a netflow-style CSV — results appear in a sortable table, with anomalous flows highlighted in red. Click "Use bundled sample data" to try it instantly with no file of your own. |
| **Deepfake** | Honestly-labeled stub — lets you select an audio/image/video file, but reports "unknown" rather than a fake result, explaining why (see README for details). |
| **Zero Trust** | Pick a user, role, target resource, device health, and location, then click "Evaluate access request" to see the ALLOW / STEP_UP_AUTH / DENY decision and why. |

The header bar shows whether VirusTotal/AbuseIPDB API keys are detected.
Long operations (training, netflow scoring, live lookups) run in the
background so the window stays responsive — you'll briefly see "scanning…"
on the badge while it works.

---

## 5. Common problems

**"python: command not found" (Linux) / "'python' is not recognized" (Windows)**
Python isn't installed or isn't on your PATH. Reinstall it and make sure to
check "Add to PATH" on Windows, or install via your package manager on Linux.

**`ModuleNotFoundError: No module named 'amelix'`, or commands only work
from inside the project folder**
You either forgot to activate the virtual environment (`(venv)` should show
in your prompt) or forgot to run `pip install -e .` from Step 1.5/2.5.
That command is what registers `amelix` with Python so it can be imported
**from any directory**, not just the project folder, and it also creates
two shortcut commands you can run from anywhere once installed:
```bash
amelix scan-url "http://example.com"
amelix-gui
```
Test the fix from a totally different folder, e.g. `cd ~ && amelix-gui`.

**Every threat-intel lookup says `"no_api_key"`**
Your `.env` file is missing, empty, or wasn't saved in the project root.
Double check `.env` exists next to `README.md` and contains real keys with
no quotes around them, e.g. `VIRUSTOTAL_API_KEY=abcdef123456`.

**PowerShell won't let me activate the venv**
Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` once (see Step 1.4).

**I want to reset everything and start clean**
Delete the `venv/` folder, the `models/*.joblib` files, and the
`.amelix_cache/` folder, then repeat from Step 1.3 / 2.3.
