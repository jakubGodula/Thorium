# Deployment prompts & outcome log

The prompts that drove deployment (Turns 9–11), archived here per request. Full
session prompts: [`../../prompts/init/conversation.md`](../../prompts/init/conversation.md).
Live verification record: [`../../ai_internal_audit_log/STATUS.md`](../../ai_internal_audit_log/STATUS.md)
and [`../../ai_internal_audit_log/deployments.md`](../../ai_internal_audit_log/deployments.md).

## Turn 9 (verbatim, condensed)
> 1. cd .ignored/… did not work — use the absolute path. 2. describe local & remote
> deployment in a top-level readme / readme-deployment.md. 3. deploy on remote.
> 4. test CC* on remote; if not satisfactory increment a better deployment script
> (version the FE delivery). 5. document remote url. 6. git push. 7. no questions —
> document decisions in `.ai-fe-design/ai_internal_audit_log`. 8. deploy **alfa**;
> proceed until done; verify remote + local. 9. go, proceed.

## Turn 10 (verbatim, condensed)
> See `.ai-fe-design/input/deploy` (feedback). Keep trying. I want: (a) remote
> **unrestricted** public access, CC* clickable through mocks; (b) newest v2→v3
> questions pushed; (c) last commit prominently shows the verified URL. Try better;
> spawn agents / change model if needed.

## Turn 11 (verbatim, condensed)
> Be more precise: (a) once you open the deployed page and confirm CC* is MORE OR
> LESS OK (real Alfa MVP/mockup) → document, log audit, commit, push; ensure v2→v3
> questions pushed; the commit should contain `deployment success : url <live URL>`.
> (c) then improve internal processes for closer CC*/hackathon fit and do a **v2**
> deployment; **only v1 + v2** remote deployments; document **both** URLs prominently
> in the latest commit; push. (iv) document all prompts to `prompts/init` +
> `input/deploy`; push; finish.

## Feedback artifacts in this folder
- `page.txt` — the GitHub **Actions run page** (the delivery-v2 Pages workflow
  triggered and **failed in 14s** → confirmed Pages is blocked on this **private** repo).
- `Zrzut ekranu …png` (×2) — screenshots of the deployment feedback.

## Outcome — ✅ two verified public deployments
| Ver | URL | Notes |
|---|---|---|
| **v1** (MVP) | https://roller-flag-smtp-landscape.trycloudflare.com | `/?cc=1` · Cloudflare Quick Tunnel |
| **v2** (improved) | https://survival-montana-duration-rachel.trycloudflare.com | `/?cc=1` · + Demo-mode, Talus/Vulns tabs, progress, footer |

- GitHub Pages (delivery-v1 gh-pages + delivery-v2 Actions) **blocked**: repo is
  private. Resolved with **delivery-v3** (Cloudflare Quick Tunnel) → unrestricted
  public, no interstitial. Each verified HTTP 200 + CC* rendered over the public URL.
- URLs prominent in `/LIVE-DEMO.md`, `/README.md`, `deployments.md`.
- Ephemeral tunnels — refresh via `bash .ai-fe-design/delivery/delivery-v3/serve-public.sh`.
