# Thorium — Testnet Deployments

> **You are reading the on-chain artifact registry.** It records the `PackageID`, shared `Policy` object ID, and capability object IDs as they appear on Sui testnet. For deployment *procedure*, see `docs/manual/run-move-publish.md` (created when Phase 1 Week 2 lands). For the file map of `.ai/`, see `.ai/README.md`.
>
> One section per deployment; keep the most recent at the top. Always include the Sui Explorer link.

## Current deployment

- **Network:** Sui testnet
- **PackageID:** _(not yet published)_
- **Default Policy Object ID:** _(not yet published)_
- **AdminCap Object ID:** _(not yet published)_
- **IncidentResponderCap Object ID:** _(not yet published)_
- **Last deployed:** _(not yet published)_
- **Deployed by:** _(unset)_
- **Explorer link:** _(unset)_
- **Notes:** Created as placeholder by 2026-05-24 reconciliation pass. Populate from Week 2 publish task in `detailed-roadmap.md`.

## Previous deployments

_(none yet)_

---

## How to populate

After `sui client publish --gas-budget <n>` succeeds:

1. Copy the new `PackageID` from the publish output's "Created Objects" / "Published Object" section.
2. The `init` function publishes a default `Policy` (shared object) and transfers `AdminCap` to the publisher — record both.
3. (Phase 3) When `IncidentResponderCap` is minted, record it here too.
4. Update `Last deployed` to today's date.
5. Add the Sui Explorer link: `https://suiscan.xyz/testnet/object/<PackageID>`.
6. If a new package is published (e.g., after a breaking Move change), move the current section to "Previous deployments" with a date heading.
