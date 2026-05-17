# WealthView — Moroccan Markets Dashboard

A real-time market dashboard for the Moroccan financial market, built as a single self-contained HTML file. No backend. No server cost. Open it in a browser and live data starts flowing.

**Live demo:** _(GitHub Pages URL will go here once published)_

![WealthView screenshot — Marchés tab](docs/screenshot-markets.png)

---

## What it shows

**Marchés (Markets) tab**
- Major indices: MASI (Casablanca), CAC 40, S&P 500
- Forex pairs vs. Moroccan Dirham: EUR, USD, GBP, CHF, CAD
- Top 20 weighted equities on the Casablanca Stock Exchange with logos and live price flashes
- Commodities: Gold, Brent crude, Silver, Wheat
- Moroccan Treasury Bill (BDT) yield curve — primary auctions (Bank Al-Maghrib) and secondary market
- Primary-vs-secondary spread analysis with pressure/relief interpretation

**Obligations (Bonds) tab**
- Live Moroccan Treasury Bill rates across 8 maturities (13w → 20y)
- Yield curve bar chart

Values flash cyan on change. Every panel has its own status indicator.

---

## How it works

```
┌──────────────────────────────────────────────────────────────────┐
│                    TradingView WebSocket                         │
│      (primary feed — same socket the tradingview.com charts use) │
└──────────────────────┬───────────────────────────────────────────┘
                       │ fails / rate-limited
                       ▼
┌──────────────────────────────────────────────────────────────────┐
│                Yahoo Finance API (15-min delayed)                │
│              fallback via free CORS proxies                      │
└──────────────────────┬───────────────────────────────────────────┘
                       │ fails
                       ▼
┌──────────────────────────────────────────────────────────────────┐
│              Static reference values baked into the page         │
│        (always visible — dashboard never shows blanks)           │
└──────────────────────────────────────────────────────────────────┘
```

A small badge in the top-right (`TradingView Live` / `Yahoo` / `—`) tells you which source is currently active.

For Moroccan Treasury Bill rates, the dashboard tries [bourse.ma](https://www.bourse.ma) and Bank Al-Maghrib via CORS proxy, and falls back to a snapshot of the latest published reference rates.

---

## Stack

| Layer | Library / API |
|---|---|
| Charts | Chart.js 4.4.6 (CDN, with 2 fallback CDNs) |
| Modal charts | TradingView Advanced Charting Library (`tv.js`) |
| Market data | TradingView Scanner WebSocket + Yahoo Finance |
| Moroccan rates | Bank Al-Maghrib + bourse.ma via [corsproxy.io](https://corsproxy.io) / [allorigins](https://allorigins.win) |
| Fonts | Inter, JetBrains Mono (Google Fonts) |
| Local launchers | Python `http.server` |

The entire app is one 3,243-line `index.html`. No build step, no `npm install`, no transpilation. Open in browser → it works.

---

## Run locally

**macOS**
```bash
./start.command          # or double-click in Finder
```

**Windows**
```
Lancer-WealthView.bat    (double-click)
```

**Linux**
```bash
bash start.sh
```

**Or just**
```bash
python3 -m http.server 8080
# then open http://localhost:8080
```

All scripts open `http://localhost:8080/` automatically in your default browser.

---

## Deploy to GitHub Pages

1. Push this repo to GitHub
2. Settings → Pages → Source: `main` branch / `(root)` folder → Save
3. Wait ~60 seconds → your dashboard is live at `https://<username>.github.io/<repo>/`

No build configuration needed.

---

## Public version vs. full version

This repository contains the **public demo** of WealthView. It was originally built as a more comprehensive internal tool for a private banking team. Several sections present in the full version were removed before publishing — notably a live mutual-fund (OPCVM) NAV tracking module that integrated with a Moroccan asset manager.

See [PUBLIC-VS-PRIVATE.md](PUBLIC-VS-PRIVATE.md) for a detailed list of what's in the public version vs. what's not, and why.

The public version contains:
- No internal company names, deployment context, or client data
- No proprietary fund lists or asset-manager integrations
- No internal user-facing documentation or employer references

All data shown comes from public providers fetched live at runtime.

---

## Disclaimer

This dashboard is a personal project published as a portfolio demo. All market data is fetched from public sources at runtime — nothing is stored or transmitted. Company logos shown alongside ticker symbols are property of their respective trademark owners and are used purely for instrument identification (nominative fair use), the same convention used by Yahoo Finance, Bloomberg, MarketWatch, TradingView, and other financial sites. WealthView is not affiliated with, endorsed by, or partnered with any displayed company, exchange, data provider, or financial institution.

Information shown is for informational purposes only and is not investment advice.

---

## License

MIT — see [LICENSE](LICENSE).
