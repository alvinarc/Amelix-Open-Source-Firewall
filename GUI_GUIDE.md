# Amelix GUI — Step-by-Step Guide

This file covers **only** the desktop GUI, start to finish. If you want the
command-line version instead, see `SETUP_GUIDE.md`. Follow the section for
your operating system, in order.

---

## 0. Running it from anywhere (not just the project folder)

**Easiest option: use the launcher scripts.** `launch_gui.bat` (Windows) or
`launch_gui.sh` (Linux), sitting in the project's root folder, handle
everything automatically — creating the virtual environment, installing
dependencies, and opening the GUI — and they work correctly no matter
where the project folder lives or what directory you run them from,
because they always resolve their own location first (`%~dp0` on Windows,
`$(dirname "$0")` on Linux) before doing anything else. Just double-click
`launch_gui.bat`, or run `./launch_gui.sh` from a terminal, and you're done
— you can skip straight to **Section 3** below.

The rest of this section explains the manual setup, and why
`pip install -e .` (Step 5/7 below) doesn't just install dependencies — it
registers the `amelix` package itself with Python, so it can be imported
**from any directory**, not just when your terminal's current folder is the
project root. As long as your virtual environment is activated, all of
these work identically no matter where your terminal is currently sitting:

```bash
python -m amelix.gui      # launches the GUI
python -m amelix.cli ...  # runs the CLI
```

The install also creates two plain commands you can run directly, with no
`python -m` needed at all:

```bash
amelix-gui        # launches the GUI
amelix scan-url "http://example.com"   # runs any CLI subcommand
```

If `python -m amelix.gui` only works when you `cd` into the project folder
first, it means `pip install -e .` was never actually run in your active
virtual environment — see the troubleshooting entry near the bottom of this
file.

---

## 1. Windows — Step by Step

### Step 1 — Check Python is installed
Open **PowerShell** and run:
```powershell
python --version
```
You need 3.10 or newer. If it's missing, install from
https://www.python.org/downloads/ — during install, check the box
**"Add Python to PATH"**. Reopen PowerShell afterward and re-run the command.

### Step 2 — Go to the project folder
```powershell
cd C:\path\to\amelix
```
Replace with wherever you extracted the zip — the folder containing
`README.md`, `pyproject.toml`, and the `amelix\` subfolder.

### Step 3 — Create a virtual environment
```powershell
python -m venv venv
```

### Step 4 — Activate it
```powershell
venv\Scripts\Activate.ps1
```
Your prompt should now start with `(venv)`. If PowerShell blocks the script
with an execution-policy error, run this once and try again:
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### Step 5 — Install dependencies
```powershell
pip install -r requirements.txt
pip install -e .
```
Tkinter (the GUI toolkit) ships with Python on Windows already — nothing
extra to install for the GUI itself.

### Step 6 — Add your API keys (optional, but recommended)
```powershell
copy .env.example .env
notepad .env
```
Fill in:
```
VIRUSTOTAL_API_KEY=your_key_here
ABUSEIPDB_API_KEY=your_key_here
```
Save and close. Without keys, the GUI still runs fully — threat-intel
lookups will just show `no_api_key` until you add real keys.

### Step 7 — Launch the GUI
```powershell
python -m amelix.gui
```
Or, now that it's installed, just:
```powershell
amelix-gui
```
Either works, from any folder, as long as `(venv)` is active. A window
titled **"Amelix — AI Security Firewall"** should open within a second or
two, with a row of tabs across the top.

### Step 8 — Confirm it's working
In the header bar at the top right, you should see something like:
```
VirusTotal: connected   |   AbuseIPDB: connected
```
(or `no key` if you skipped Step 6 — that's fine, it's not an error).

Click the **Phishing / Email** tab, leave the sample URL in the box, and
click **Scan URL**. Within a second, a red badge reading
`PHISHING   risk: 0.99` should appear and the console below should fill
with JSON details. That confirms everything is wired up correctly.

You're done. Jump to **Section 3: Walking Through Every Tab** below.

---

## 2. Linux — Step by Step

### Step 1 — Check Python is installed
```bash
python3 --version
```
Need 3.10+. If missing:
```bash
sudo apt update && sudo apt install python3 python3-venv python3-pip
```
(use your distro's package manager if not Debian/Ubuntu-based)

### Step 2 — Install Tkinter (Linux packages Python and Tk separately)
```bash
sudo apt install python3-tk        # Debian/Ubuntu
sudo dnf install python3-tkinter   # Fedora
sudo pacman -S tk                  # Arch
```
Skipping this step is the #1 reason the GUI fails to launch on Linux — do
this before continuing.

### Step 3 — Go to the project folder
```bash
cd ~/amelix
```
(wherever you extracted the zip)

### Step 4 — Create a virtual environment with system packages enabled
This is important: the venv needs `--system-site-packages` so it can see
the `python3-tk` package you just installed system-wide.
```bash
python3 -m venv venv --system-site-packages
```

### Step 5 — Activate it
```bash
source venv/bin/activate
```
Your prompt should now start with `(venv)`.

### Step 6 — Verify Tkinter is visible inside the venv
```bash
python -c "import tkinter; print('tkinter OK')"
```
If this errors, go back to Step 2 and Step 4 — the venv was likely created
before Tk was installed, or without `--system-site-packages`. Delete the
`venv` folder and redo Steps 4-5.

### Step 7 — Install dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
pip install -e .
```

### Step 8 — Add your API keys (optional, but recommended)
```bash
cp .env.example .env
nano .env
```
Fill in:
```
VIRUSTOTAL_API_KEY=your_key_here
ABUSEIPDB_API_KEY=your_key_here
```
Save with `Ctrl+O`, `Enter`, exit with `Ctrl+X`.

### Step 9 — Launch the GUI
```bash
python -m amelix.gui
```
Or, now that it's installed, just:
```bash
amelix-gui
```
Either works, from any folder, as long as `(venv)` is active. A window
titled **"Amelix — AI Security Firewall"** should open.

> **Running over SSH / no local display?** The GUI needs a display server.
> Either run it directly on the machine's desktop, forward X11
> (`ssh -X user@host`), or use a virtual display for headless testing:
> `sudo apt install xvfb` then `xvfb-run python -m amelix.gui`
> (note: `xvfb-run` shows nothing on screen — it's for automated testing
> only, not everyday use).

### Step 10 — Confirm it's working
Click the **Phishing / Email** tab, leave the sample URL in place, and
click **Scan URL**. A red `PHISHING   risk: 0.99` badge should appear
within a second, with full JSON output below it.

You're done. Continue to **Section 3: Walking Through Every Tab** below.

---

## 3. Walking Through Every Tab

Once the window is open, here's what to do in each tab. Every action shows
its result in the console pane at the bottom of the tab and, where
applicable, a colored badge (🟢 green = safe, 🟡 yellow = suspicious,
🔴 red = malicious/blocked).

### Phishing / Email
1. Type or paste a URL into the box and click **Scan URL** — OR —
2. Click **Load .eml file & scan email** and pick a file (try
   `samples/phish_sample.eml` and `samples/legit_sample.eml` first).
3. Click **Train / retrain phishing model** any time you've edited
   `data/phishing_urls_sample.csv` with your own labeled examples.

### SMS / Scam
1. Type or paste a text message into the box.
2. Click **Scan message**.

### Malware / Files
1. Click **Scan a single file** and pick any file — try creating a random
   file to see a "suspicious" verdict, or scan a normal document to see
   "clean"/"unknown".
2. Or click **Scan a folder** to scan every file inside it at once.

### Quishing (QR)
1. Click **Scan a QR code image** and pick a photo or screenshot containing
   a QR code — try the bundled `samples/quishing_sample.png` first, which
   encodes a known-malicious test URL and should come back `QUISHING`.
2. Don't have a QR image handy? Click **Generate a test QR code…**, type
   any URL or text, and save it — then scan the file you just created.
3. Non-URL QR codes (WiFi configs, contact cards, phone numbers) get their
   own risk assessment instead of the phishing model — e.g. an open/guest
   auto-join WiFi QR is flagged as a classic "evil twin" attack pattern.

### Threat Intel
1. Type an IP address and click **Check IP** (uses AbuseIPDB).
2. Type a domain and click **Check Domain** (uses VirusTotal).
3. To permanently block something yourself, type it into the blocklist box
   and click **Add** — future scans of that indicator will always come
   back "blocked" regardless of what the ML model or reputation says.

### Network Anomaly
1. Click **Use bundled sample data** for an instant demo — the table fills
   with 24 sample network flows, with the anomalous ones (a C2-beacon-like
   connection, a large SSH transfer, etc.) highlighted in red.
2. Or click **Load & score netflow CSV** to score your own flow data (same
   columns as `data/sample_netflow.csv`: src_ip, dst_ip, dst_port,
   protocol, duration_sec, bytes_sent, bytes_recv, packets).
3. Click **Train anomaly model** any time you want to retrain on new data.

### Deepfake
This tab is intentionally honest about its limits — read the yellow notice
at the top. Selecting an audio or image/video file will return
`verdict: "unknown"` with an explanation, rather than a fake result.

### Zero Trust
1. Fill in a user name, pick a role, pick a target resource, pick a device
   health status, and a location.
2. Click **Evaluate access request**.
3. Try a few combinations to see how the decision changes — e.g. role
   `employee` against resource `finance-db` should DENY (role too low),
   while device health `jailbroken_rooted` should DENY on anything.

---

## 4. Troubleshooting

**Nothing happens when I run `python -m amelix.gui`**
Make sure your virtual environment is activated — you should see `(venv)`
at the start of your terminal prompt. If not, go back to Step 4/5 (Windows)
or Step 5 (Linux) above.

**`ModuleNotFoundError: No module named 'tkinter'` (Linux)**
You skipped Step 2. Install `python3-tk` (or your distro's equivalent),
then delete the `venv` folder and redo Steps 4 onward so the new venv is
created with `--system-site-packages`.

**`ModuleNotFoundError: No module named 'joblib'` (or 'requests', 'sklearn', 'pandas', etc.)**
This means `pip install -r requirements.txt` was never run inside the
Python environment that's actually launching the GUI — usually because the
virtual environment wasn't activated (no `(venv)` at the start of your
prompt) when you ran `python -m amelix.gui`. Fix:
```powershell
cd C:\path\to\amelix        # the folder with requirements.txt
venv\Scripts\Activate.ps1    # Linux: source venv/bin/activate
pip install -r requirements.txt
pip install -e .
python -m amelix.gui
```
If `(venv)` still doesn't appear after activating, the venv may not have
been created yet — run `python -m venv venv` first, then activate.

**`ModuleNotFoundError: No module named 'amelix'`, or `python -m amelix.gui`
only works from inside the project folder**
You forgot `pip install -e .` (Step 5/Step 7) — or ran it in a different
environment than the one you're launching from. This one command is what
makes `amelix` importable **from any directory**, and also creates the
`amelix` / `amelix-gui` shortcut commands. Run it again from the project's
root folder (where `pyproject.toml` lives), with the venv activated:
```bash
cd /path/to/amelix
# activate venv first (see Step 4/5 Windows, Step 5 Linux)
pip install -e .
```
Then test from a completely different folder to confirm it's really fixed:
```bash
cd ~
amelix-gui
```

**The window opens but every lookup says `no_api_key`**
Your `.env` file is missing or empty. Redo Step 6 (Windows) / Step 8
(Linux) and make sure the file is saved directly in the project's root
folder, next to `README.md`.

**The window is frozen / not responding**
Long operations (training, live API lookups) run in the background and
shouldn't freeze the window — if it does freeze for more than a few
seconds, it may be a slow/failed network call to VirusTotal or AbuseIPDB.
Wait a moment; it will time out and show an error in the console rather
than hang forever.

**I'm on Linux over SSH and get a `no display name` / `couldn't connect to
display` error**
The GUI needs a graphical display. Either run it on the machine's own
desktop session, or reconnect with `ssh -X user@host` to forward the
display over SSH.
