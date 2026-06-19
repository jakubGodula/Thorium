# Thorium XDR — Brand assets (suggested)

> **Suggestions only** (answer Q14 / v2→v3 R17). Replace when official brand
> assets arrive. These are SVG so they stay crisp and IPFS-light.

## Mark
- [`thorium-mark.svg`](./thorium-mark.svg) — full logo mark (128×128).
- [`favicon.svg`](./favicon.svg) — favicon / app icon (32×32).

**Concept:** a **shield** (XDR / defense / endpoint protection) fused with an
**atomic orbit + element symbol "Th"** — *Thorium*, atomic number 90. It ties the
security product to its namesake element and reads at small sizes.

## Palette
| Token | Hex | Use |
|---|---|---|
| `--accent` (Thorium cyan) | `#38bdf8` | primary brand / active / focus |
| `--accent-2` (Walrus mint) | `#5eead4` | on-chain / provenance / secondary |
| `--bg-0 … --bg-3` | `#0a0e1a … #1d2436` | dark SOC surfaces |
| severity | red/orange/amber/yellow/green | `CRITICAL…LOW` (see v1 §3.1) |

Gradient `#38bdf8 → #5eead4` is the signature (logo, key CTAs, glow). Keep glow
subtle and `prefers-reduced-motion`-aware.

## Usage
- Wire `favicon.svg` into `ui/public/` (replace the Vite default).
- Use `thorium-mark.svg` in the top-bar logo next to "Thorium XDR".
- Typography: system UI stack; mono (`ui-monospace`) for hashes/addresses/commands.

## To do (official)
- High-res raster fallbacks (PNG 512/192/180 for PWA/Apple touch).
- Wordmark lockup + clear-space rules.
- Confirm cyan vs an official brand hue (R17).
