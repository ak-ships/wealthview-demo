# Public version vs. full version

The full WealthView dashboard was built as an internal tool for a private banking team in Morocco. This public version on GitHub is the same dashboard with internal-only sections removed.

This document describes **what was removed and why**, without disclosing any of the actual internal content.

---

## What's identical between the two versions

The market data half of the dashboard is exactly the same in both versions:

- Indices (MASI, CAC 40, S&P 500)
- Forex pairs vs. MAD
- Top 20 Casablanca Stock Exchange equities (live price flashes, logos, modal TradingView charts)
- Commodities (Gold, Brent, Silver, Wheat)
- Bank Al-Maghrib Treasury Bill yield curve
- Primary-vs-secondary market spread chart
- Live BDT rates table

All of this runs on public APIs (TradingView WebSocket, Yahoo Finance, bourse.ma, Bank Al-Maghrib) and contains no internal data.

---

## What was removed for the public version

### 1. Live mutual-fund (OPCVM) NAV tracking module

**What it was:**
A live integration with a Moroccan asset manager's NAV publication feed. The full version pulled net asset values (VL — *valeurs liquidatives*) for ~10 fund instruments across the standard OPCVM categories (monetary, short-term bonds, long-term bonds, balanced/mixed, equity), refreshed several times a day, with YTD, 1-month, 1-week, and daily-change performance metrics, plus a YTD performance ranking bar chart and per-fund 30-day sparklines.

**Why it was removed:**
The integration was specific to one asset manager's public NAV publication page. Including those fund names and the integration code in a public repo would:

1. Identify the institution the dashboard was deployed at
2. Suggest a partnership or endorsement that doesn't exist
3. Single out one asset manager among Morocco's many fund providers — an aesthetic and editorial choice for an internal tool, but not appropriate for a public demo

**Architecture (preserved as stubs in the code):**
- A custom HTML parser for the asset manager's tabular VL publication page (column-mapped: name, ISIN, NAV, AUM, fees, weekly/monthly/3-month/YTD/1-year performance)
- Cross-day delta computation using `localStorage` snapshots (compare today's published NAV against yesterday's stored snapshot for an exact ΔJ in MAD)
- Fallback to `perf1w ÷ 5` estimation when no prior snapshot exists (with `~` prefix to mark estimates)
- Smart polling scheduler aligned to the Moroccan stock exchange clock: aggressive polling during the publication window (16h–19h Morocco time), passive checks during market hours (10-min intervals), idle overnight
- Multi-source fallback chain (primary asset-manager site → ASFIM aggregator → casablanca-bourse.com)

The stub function bodies in [index.html](index.html) (search for `// removed in public version`) mark exactly where this code lived.

### 2. Internal deployment and onboarding documentation

The original distribution included:

- A French-language IT handover document for the bank's IT team (logging paths, port conflicts, AV exceptions, kiosk setup)
- A French-language end-user guide for the banking team
- The installation email sent to internal IT
- A packaged zip for internal distribution
- A nested folder mirroring the deployment structure

None of these are in the public repo. The launcher scripts ([start.sh](start.sh), [Lancer-WealthView.bat](Lancer-WealthView.bat), etc.) were generic from the start — they just bootstrap a local Python `http.server` — and are unchanged.

### 3. Branding and framing

The full version's title bar and footer named the dashboard as a *Private Banking Dashboard* tailored for a specific team. The public version is rebranded as a *Moroccan Markets Dashboard · Public Demo* with a generic disclaimer footer. No employer logo or attribution was ever baked into the HTML, so nothing visual changed beyond the subtitle and footer text.

---

## Why none of this content is in this repo

I followed three rules when preparing the public version:

1. **No identification of the employer** — direct or indirect (no internal product names, no fund lists tied to one provider, no IT environment specifics).
2. **No client data of any kind** — the dashboard never stored client information to begin with (market data is fetched live), but removing the internal modules removes any ambiguity.
3. **No documentation that would reveal internal processes** — IT handovers, deployment guides, and the original distribution email were all excluded.

The market data half of the dashboard works identically to the full version because it was built on public APIs from day one.

---

## If you're curious about the removed modules

The mutual-fund tracking module is the more interesting piece technically — cross-day delta tracking with localStorage, smart polling against an exchange clock, multi-source fallback, weekly-performance-based estimation when historical data is unavailable. If you're building something similar for a different market and want to discuss the design, feel free to open an issue.
