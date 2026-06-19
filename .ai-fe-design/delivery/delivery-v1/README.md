# FE delivery **v1** — gh-pages branch deploy

Push the prebuilt static `dist/` to a `gh-pages` branch via SSH.

```bash
bash .ai-fe-design/delivery/delivery-v1/deploy.sh
```

**Status / limitation:** the branch publishes fine, but GitHub Pages must be
**enabled once** in repo **Settings → Pages → Branch: `gh-pages` / root** (this needs
the web UI or an authenticated `gh`/token — not available to the autonomous agent).
Until then the URL 404s. Superseded by **[delivery-v2](../delivery-v2/)** which
auto-enables Pages via GitHub Actions.

Live (once enabled): **https://jakubgodula.github.io/Thorium/** (`?cc=1` for the alert).
