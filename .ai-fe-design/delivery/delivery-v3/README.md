# FE delivery **v3** — unrestricted public URL (Cloudflare Quick Tunnel)

The delivery that actually produced a **public, unrestricted, clickable** live demo
when GitHub Pages was blocked (private repo) and localtunnel showed an interstitial.

```bash
bash .ai-fe-design/delivery/delivery-v3/serve-public.sh
# → prints a https://<random>.trycloudflare.com URL (live while the script runs)
```

- **No login, no interstitial** — Cloudflare Quick Tunnel. Fully public + clickable.
- Serves the **Alfa** build (`:5173`); CC\* runs on client-side fixtures (no backend).
- **Ephemeral:** URL is random per run and lives only while the process runs.

**Last verified URL:** see [`/LIVE-DEMO.md`](../../../LIVE-DEMO.md) (kept prominent at
repo root). For a **durable** URL, use delivery-v1/v2 (GitHub Pages) once the repo is
public / Pages-enabled.

## Delivery matrix
| Delivery | Mechanism | Public? | Durable? | Status |
|---|---|---|---|---|
| v1 | `gh-pages` branch | needs Pages enable | yes | pushed; Pages off (private repo) |
| v2 | Actions → Pages (auto-enable) | needs Pages on private | yes | workflow ran, failed (private repo) |
| **v3** | **Cloudflare Quick Tunnel** | **yes, unrestricted** | no (ephemeral) | **✅ verified live** |
