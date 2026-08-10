<p align="center">
  <img src="logoamelixfw.png" alt="Amelix Firewall logo" width="200">
</p>

<!-- The logo above is embedded directly as base64 so it always renders,
     regardless of relative paths, git status, or how README.md is opened.
     A full-resolution copy of the original artwork also ships at
     amelix/assets/logoamelixfw.png if you want to use it elsewhere. -->

# Amelix AI Security Firewall — v0.1 (Working Core Scaffold)

**Author:** Adlarc

Amelix is a modular, cross-platform (Windows + Linux) security agent written in
Python. This is a **real, runnable core** — not a mockup — but it is honestly
scoped: some capabilities are fully functional today, others are stubbed with a
clean interface so you (or a security ML team) can plug in trained models later.

## What's REAL and working right now

| Module | Status | How it works |
|---|---|---|
| Phishing URL/Email detector | ✅ Real ML | Logistic Regression on hand-engineered URL/email features. Trains in seconds on the bundled sample dataset; retrain on your own data anytime. |
| SMS/Message scam detector | ✅ Real (heuristic + ML) | Same feature-pipeline approach applied to short text messages (urgency words, links, spoofed sender patterns, entropy). |
| Threat Intelligence lookups | ✅ Real | Live calls to VirusTotal (file hash / domain / IP) and AbuseIPDB (IP reputation), with local caching + a local blocklist you control. |
| File / hash malware scan | ✅ Real | SHA-256 hashing of files, VirusTotal reputation lookup, plus local entropy-based packing/encryption heuristic (flags likely-obfuscated binaries). |
| Network anomaly detection | ✅ Real ML | Isolation Forest trained on flow-level features (bytes, duration, packet count, port entropy). Ships with a synthetic training set; swap in real NetFlow/Zeek logs. |
| Zero Trust policy engine | ✅ Real | Identity + device posture + role + live risk score → ALLOW / STEP-UP-AUTH / DENY decision, with per-resource microsegmentation rules. |
| Behavioral analytics (basic) | ✅ Real | Rolling per-user baseline (login times, locations, volume) → deviation score feeds the risk engine above. |
| Quishing (QR-code phishing) detector | ✅ Real | Decodes QR codes (OpenCV, no external zbar dependency), classifies the payload type (URL, WiFi config, contact card, phone number, crypto payment, plain text), and scores URL payloads with the same phishing ML model plus QR-specific risk weighting (link-shortener/aggregator prevalence, lure keywords, and a deliberate risk boost because QR delivery bypasses the normal human habit of previewing a link). Non-URL payloads get their own real heuristics — e.g. an open/guest auto-join WiFi QR is flagged as a classic "evil twin" attack vector. |

## What's an HONEST STUB (interface only, not a working detector)

| Module | Why it's a stub |
|---|---|
| Voice deepfake detection | Needs a trained audio spoofing-detection model (e.g. on ASVspoof-style data) and a spectrogram/embedding pipeline. The interface (`modules/deepfake/voice.py`) is ready to accept a model — none is bundled because it can't be trained meaningfully without real labeled data and GPU time. |
| Image/video deepfake detection | Same reasoning — interface ready (`modules/deepfake/video.py`), no bundled model. |
| "Predict attacks before signatures exist" | Not a real, deliverable capability from anyone today. What we actually ship (anomaly detection + behavioral analytics) is the honest version of this: it flags *deviation*, not specific unknown attacks. |
| True zero-day malware blocking | We ship real heuristics (entropy, reputation, behavior) that catch a meaningful slice of unknown threats, but no vendor can guarantee blocking all zero-days. Treat detections as high-priority alerts, not guarantees. |
| Kubernetes/Docker/serverless microsegmentation, dark-web monitoring | These need live infra access / paid feeds and are out of scope for a local prototype. The zero-trust engine's microsegmentation rules are written so they *can* be wired into a Kubernetes NetworkPolicy or cloud security-group generator later — that adapter isn't built yet. |

## Quickest start: one-click launchers

If you don't want to touch the terminal at all, use the launcher scripts in
the project root — they find their own folder automatically, so they work
no matter where the project is located or which directory you run them from:

| File | What it does |
|---|---|
| `launch_gui.bat` (Windows) / `launch_gui.sh` (Linux) | Sets up the virtual environment on first run, installs everything needed, and opens the GUI. Double-click it (Windows) or run `./launch_gui.sh` (Linux). |
| `launch_cli.bat` (Windows) / `launch_cli.sh` (Linux) | Same setup, but drops you into a terminal with the `amelix` command ready to use. |

Every subsequent run just reuses the existing environment and launches
straight away. See `SETUP_GUIDE.md` / `GUI_GUIDE.md` for the full manual
walkthrough if you'd rather set it up yourself step by step.

## GUI

A cross-platform desktop GUI (Tkinter, no extra deps beyond the OS's own
Tk package) is included: `python -m amelix.gui` or `amelix-gui` after
install. It wraps every module in this README with tabs, file pickers, and
a live-updating console/table, using the Amelix logo as both the window
icon and the header branding — see `SETUP_GUIDE.md` section 4 for a full
walkthrough. The CLI (`amelix.cli`) still exists for scripting/automation.

## Setup (Windows or Linux)

```bash
python -m venv venv
# Linux/macOS
source venv/bin/activate
# Windows (PowerShell)
venv\Scripts\Activate.ps1

pip install -r requirements.txt
cp .env.example .env     # then fill in your API keys
```

## Configure API keys

Edit `.env`:

```
VIRUSTOTAL_API_KEY=your_key_here
ABUSEIPDB_API_KEY=your_key_here
```

## Usage

```bash
# Train the phishing model on the bundled sample data (takes ~2 seconds)
python -m amelix.cli train-phishing

# Scan a URL
python -m amelix.cli scan-url "http://paypal-secure-login.verify-account.tk/reset"

# Scan an email (from a .eml file or raw text file)
python -m amelix.cli scan-email samples/phish_sample.eml

# Scan an SMS/message
python -m amelix.cli scan-sms "URGENT: Your bank account has been suspended, verify now: bit.ly/2xk9s"

# Scan a QR code image for quishing (QR phishing) risk
python -m amelix.cli scan-qr samples/quishing_sample.png

# Generate your own test QR code to try scan-qr with
python -m amelix.cli make-test-qr "http://bit.ly/some-test-link" samples/my_test_qr.png

# Hash + reputation-check a file
python -m amelix.cli scan-file /path/to/suspicious.exe

# Check an IP or domain against threat intel
python -m amelix.cli check-ip 45.146.164.110
python -m amelix.cli check-domain paypal-secure-login.verify-account.tk

# Train + run network anomaly detection on a flow CSV
python -m amelix.cli train-netmodel
python -m amelix.cli scan-netflow data/sample_netflow.csv

# Evaluate a Zero Trust access decision
python -m amelix.cli policy-eval --user alice --role employee --device-health healthy --resource finance-db --location "new office"
```

## Architecture

```
amelix/
  core/
    config.py          # env/config loading
    policy_engine.py    # Zero Trust decision engine (identity+device+risk+role)
    risk_engine.py       # behavioral baselining + risk scoring
  modules/
    phishing/            # URL + email phishing ML detector
    sms_scam/             # SMS/message scam detector
    quishing/              # QR-code phishing (quishing) decoder + scorer
    threat_intel/          # VirusTotal / AbuseIPDB clients + local blocklist + cache
    malware/                # file hashing, reputation, entropy heuristic
    network_anomaly/         # Isolation Forest flow anomaly detector
    deepfake/                  # voice.py / video.py — STUB interfaces, no bundled model
  cli.py                        # unified command-line entry point
```

## Extending this into a full product

Realistic next steps, roughly in order of effort:
1. Wire the policy engine's microsegmentation output into real firewall rules
   (iptables/nftables on Linux, WFP/Windows Firewall API on Windows).
2. Replace the sample phishing/SMS datasets with real labeled corpora
   (PhishTank, OpenPhish, a labeled SMS spam corpus) and retrain.
3. Feed real NetFlow/Zeek/Suricata logs into the anomaly detector instead of
   the synthetic sample.
4. For deepfake detection: integrate an existing open-source detector
   (e.g. a published audio anti-spoofing model or a video deepfake classifier)
   behind the stub interfaces, or partner with a team that has one trained.
5. Add a lightweight local agent service (systemd unit on Linux, Windows
   Service via `pywin32`) that runs these checks continuously and feeds a
   central dashboard.
