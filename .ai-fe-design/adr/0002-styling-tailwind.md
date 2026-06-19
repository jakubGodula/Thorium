# ADR-0002: Tailwind CSS for styling

**Status:** Accepted (v2) — overrides v1's "plain CSS tokens"
**Date:** 2026-06-19

## Context
v1 recommended plain CSS custom properties to stay IPFS-light. The user chose
**Tailwind** (Q3) and set a high visual bar (Stripe/Bolt/ELK/Walrus), where
"heavy is OK early." The current `App.svelte` is a mass of inline styles.

## Decision
Adopt **Tailwind CSS** (v4, CSS-first `@theme`). The v1 §3.1 design tokens become
the Tailwind theme (colors, severity/status scales, radii, shadow, spacing) — the
single source of truth. Components use utilities; headless primitives via
**shadcn-svelte / bits-ui** for accessibility.

## Consequences
- + Fast, consistent, professional UI; easy density/spacing rhythm.
- + Re-theming = edit the theme block.
- + Purged CSS is small and static-host friendly.
- − Build-time toolchain (PostCSS/Tailwind) added vs zero-dep v1.
- − Must port existing inline styles during the migration (v1 §10).
