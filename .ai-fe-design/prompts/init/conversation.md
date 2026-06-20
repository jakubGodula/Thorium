# Founding conversation — user prompts (verbatim)

> Every USER message from the session, in order, verbatim. Assistant replies and
> tool outputs are not reproduced (see the resulting files + `decision-log.md`).
> Inline answers the user typed into question files are preserved in the relevant
> `*_AUDIT.md`. Long repeated config blocks from turns 1–2 are stored verbatim in
> [`../../prompt_verbatim.md`](../../prompt_verbatim.md).

---

## Turn 1 — (slash command + founding prompt)

`/model` → "Set model to Opus 4.8 (1M context) (default)…"

Then (verbatim; also in `../../input/prompt.txt` and `../../prompt_verbatim.md`):

```
Praca

Hi.

Config:
- github url repo
- Local directory
- Branch name
- Target branch name
- Path to directory with context relevant - conversation, images

Config:
- github url repo
- Local directory :/Users/macbook/work/Thorium
- Branch name: experimental
- Target branch name: origin/experimental-aw-fe
- Path to directory with context relevant - conversation, images
= already existing a new directory:
.ai-fe-design/input
- a new directory named: .ai-fe-design
you see already in experimental-aw-fe branch in git staging area with .gitignore
do commit it. do not commit unversioned files

Output:
- a new directory named: .ai-fe-design
- It is not gitignored
- It contains the context of the frontend docs spec
- You will in a single prompt commit v1 of the frontend design. Based on your analisis. No asking of clarifying questions from user
- So output in a new directory named: .ai-fe-design should be:
- Have v1 version of specs for frontend team / ai agent to implement very precise.
- Have a list of clarifying contexts and questions. Ie a list of questions is for a relationship: from v1_to_v2. And you can output them in a file questions_v1_to_v2_qa.md. The user or next agent will answer these questions.
- You will commit these changes directly after user's prompt
- The commit will contain a logic for a flow from the user/ another dev/ another agent for a new named: .ai-fe-design:
- A) it contains fe_design_v1.md of a very specific as specific as possible design of thorium frontend. Also maybe suggest next steps eg using claude design or a few prompts another user may use
- B) it contains questions_v1_to_v2_qa.md with initial instructions for user having to answer these inline in .md file. Be specific which commands go run to go and use the flow ie:
- B1) user opens project on a new branch name, checks out
- B2) user explicitly in named: .ai-fe-design sees: readme.md (he knows he needs to fill in v1 to v2 answers), the v1 initial design, the folder for inputs, the folder with this prompt (yes! Save this prompt verbatim)
- The user uses antygravity or codez or claude code
- B3) the user's ai agents know what to do to perform:
a) list v1 design
b) list and answer v1 to v2 questions. note - you did an analysis
c) compute v2 after answering v1 to v2 questions

Now I would like you to do a few things in a single execution.

See tho

—
Context:
We prefer svelte or react. No hard dependencies. Lightweight.
See the repo and readmes
We will deploy it as a usual website on ipfs for which we have license

A new main directory:

Important:
- 1) execute this prompt as fast as possible
- 2) output what you can in 1 up to 5 minutes
- 3) you already have one commit. create another with ai context, v1 design, v1 to v2 questions, a guide in this directory to create v2 design
```

## Turn 1b — (mid-work instruction)

```
please remember to commit and push directly after you finish your work from commandline. do not rebase already pushed commit. only push as an end goal - after you finish all these. do not ask me for anything. just push. leave questions to v1 to v2 file. push to git after analysis
```

---

## Turn 2 — (freeze v1 branch, derive v2 branch, assumptions)

```
Praca
1. leave experimental-aw-fe as it is => DO NOT PUSH TO ORIGIN / experimental-aw-fe anymore

Hi.

[ … the same Config block as Turn 1, verbatim in ../../prompt_verbatim.md … ]

---

after some thoughts please:
1. leave experimental-aw-fe as it is => DO NOT PUSH TO ORIGIN / experimental-aw-fe anymore
2. checkout new experimental-aw-fe-v2 and push there new commits - ie. onces after this approach. So experimental-aw-fe-v2 is a derivative from experimental-aw-fe
3. output the v1 to v2 questions. output assumptions
4. I will try to output v1 to v2 answers. You will create:
=> v2 design
=> v2 to v3 questions for ambiguities and leaving the assumptions
5. we will also create a script to create the
.ignored/fe-demo
with current implementation of v3 step. but this point 5 will be a separate prompt

Use 5 to 10 mins to analyze
1. leave experimental-aw-fe as it is => DO NOT PUSH TO ORIGIN / experimental-aw-fe anymore
```

---

## Turn 3 — (answered v1→v2 questions, continue to v2)

```
I answered questions to:
/Users/macbook/work/Thorium/.ai-fe-design/questions_v1_to_v2_qa.md

see git staging

please continue

### After answering
1. Save this file (answers inline).
2. Generate fe_design_v2.md = v1 + decisions above.
3. Open questions_v2_to_v3_qa.md with the next round.
4. git add .ai-fe-design/ && git commit && git push on your v2 branch.

---
Now I expect you to continue as discussed
```

> The inline answers are preserved verbatim in
> [`../../questions_v1_to_v2_qa_AUDIT.md`](../../questions_v1_to_v2_qa_AUDIT.md).

---

## Turn 4 — (versioned demo+mock generator; ask first)

```
Now as I have v2 of the design and questions_v2_to_v3_qa.md with the next round.
:
1) re-read the outputed instructions to AI to see if you want to change or make something better for other models
2) focus on prompt (skill / folder with procedures) to based on recent (here v2, but after v3 it will be v3) frontend design.
Based on latest frontend design generate:
a) the demo
b) living demo
c) deployable demo
d) with mock and openapi spec to integrate with mocks

ask clarifying questions first.
When I expect you to do work.

Note - for demo you may output assumptions.
As we have design versioning (v1, v2, now waiting for v3) we may need the prmopt for demo and mock generation versioning.

So:
1) now we are doing the v1 demo+mock+live demo clickable on mocks based on our assumptions from v2 fe design
2) then we will iterate and probably do a better prompt for v2 demo+mock+live demo clickable on mocks based on our assumptions from v2 fe design
3) in the meatime another team will answer and generate v3 design.
So we will try to use prompt for v2 demo+mock+live demo clickable on mocks based on our assumptions from v3 fe design (that does not exist yet).

Please rephrase next steps
```

**Clarifying answers (Turn 4):** scope = author the prompt/skill only this turn, but
end with direction for "scaffold demo" + "full demo" (next, after sign-off); form =
Skill + procedure folder; versioning = pinned matrix; mock = OpenAPI 3.1 + Prism.

---

## Turn 5 — (wire-keys TODO; live demo; archive; ⭐ CC* critical demo case)

```
===
  One thing worth your input when convenient: the OpenAPI mock keeps the real Polish wire keys (kod/tresc/klucz_pub) so the contract matches the actual Mowa agent, with
  English mapping in the adapter — if you'd rather the mock expose English keys too, that's a one-line note before step 2.

=> ok. put it in the adr.md and readme with TODO tag

So:
1) make sure you are able to generate demo and (from output):
a) [scaffold demo — Vite+Svelte+Tailwind app + Prism mock running, shell + 2–3 screens wired on mocks, npm run demo boots both — gen-v1 ⊗ v2 — on your "go"]
b) [trigger step 2 by saying "go — scaffold the demo" (or /fe-demo-gen). scaffold → sign-off → full demo, all on mocks, output to .ignored/fe-demo/demo_designV2_genV1/]
c) and the live demo, link, working on local with living mocks. Everything described, easily deployable. Missing integrations (like with sui, etc) should be in generated readme.md file at top of level of the project: /Users/macbook/work/Thorium/.ai-fe-design

2) when you are sure you are able to do it, please make sure a new agent claude code / codex / antigravity will be able to also generate everything from point 1. preferably as a first point of capabilities of this project for agent in the main readme.md file of
3) then do it
4) save all prompt and all context from this chat into:
/Users/macbook/work/Thorium/.ai-fe-design/prompts
and especially this one conversation fully with attachments and inlines into:
/Users/macbook/work/Thorium/.ai-fe-design/prompts/init

5) move back to point 3) and open the app on port described in readme. iteratively make it better and state one by one requirements.

6) one more note that you may add to v2 and v3:
- in Thorium we have a critical demo case:
THIS PATH MUST BE PROMINENT AND VERY WELL VISIBLE ON FRONTEND. EVERY ELEGANT AND MODERN. explain in top readme.md the need to take into consideration this path. as critical for demo. to be added as a top comment. So it should be both in this branch in:
a) top /Users/macbook/work/Thorium/.ai-fe-design/README.md
b) v1, v2, v3 version history (yes, in this point you are making history up to include this critical case).
c) /Users/macbook/work/Thorium/.ai-fe-design/input/DEMO.md as a critical attachment
d) /Users/macbook/work/Thorium/.ai-fe-design/prompts/init as we are discussing it.
e) if you do cannot confirm below case for demo, leave the confirmation as a question in v3. for v2 we assume the below version (CC*)

So the critical case (CC*):
a) user connects a new pod into Thorium to be observed via blockchain (ie. the observed pod)
b) the observed pod is healthy and sui contract interacts with it. Visible in events / logs in Thorium UI - ie. frontend app can confirm SUI contract interaction with  and OK status in the observed pod telemetry
c) we simulate kernel attack or ddos against the observed pod
d) Thorium marks the observed pod as not worthy
d) SUI tries to interaction with it or another agent. The log and telemetry NOT OK is visible in frontend app.
e) very important and it must be perfect for demo:
the alert is visible in the frontend app we are doing v1,v2,v3 spec and deployments. It must be as good as Stripe would do it.
If you have 3-5 ways to show it, leave a question in v2 to v3 questions. But for v2 just make a decision
f) the observed pod is visible in the frontend app and in sui blockchain as not worthy. We allow the hint - ie. plaholder (alert, or "Coming soon..." on UI or dummy button and alert, a mockup). like:
- notify on-call
- integration with slack on the observed pod compromised
- freze ports, isolate pod, kill it in cloud, execute skill and a connection to claude code or a developer

make it happen. Analyze all output. I would expect:
- you ask up to 3 clarifying questions
- you will make sure to make it happen for this session and for other codex / claude code / antigravity agents
- you will do all this work but not generate demo.
the generation of demo will be after the sign-off that everything is clear. you may rephrase contexts if you are not sure. but up to 3 clarifying questions
```

**Clarifying answers (Turn 5):** capability home = **Both, maximal** (repo-root
README + `.ai-fe-design/README.md` + AGENTS.md); v3 handling = **No v3 file;
questions only**; archive fidelity = **verbatim prompts + decision log**.

---

## Turn 6 — (call it gen-v2 generation method; improve CC*)

```
now one more thing:
1) it produced effect. terrific. let's call it v2 of the generation method prompt. Please commit work
2) please commit work ie: a) input/DEMO.md b) prompts/init verbatim c) the top level in readme capabilities of this project d) the steps to generate the demo from v2 version using v2 the generation prompt (I prefer v2. but if you suggest v1, I can leave with it). e) make sure everything exists. and git commit
3) now we will work on v2 (or v3, ie. next iteration) generating demo method. So another prompt. The previous one made a terrific result. and it is ok. This work is committed.
4) now in order to achieve point 3 … we need to do:
a) you will constantly in loop or with spawned agents with eg. cheaper haiku or 4.6 model try to improve the demo. ie. the (CC*) critical path
b) you will output the screens if possible of alerts etc. from your environement if you can run it in browser / docker / disposible headless / selenium scripts. up to you. or just output the expected demo path (maybe with selenium script?)
c) make the list of v3 questions more exhaustive. add "Final chapter optional" of all choices how to do (CC*) path the best. … document in design v2 to v3 folder
Please continue. If not sure ask. But I would like you to spend 10-15 min analysing or generating demo. Up to you. After 15 mins output assumptions, clarifying questions, results
```

## Turn 7 — (two source files; restructure v2→v3 into Parts)

```
1) there are two more files … roadmap_en.html / presentation_en.html …
a) finish work b) document … in readme suitable c) compare final output with roadmap_en.html / presentation_en.html and results put into the optional 2nd / 3rd topics or rounds or groups of questions in v2 to v3 …
6) … do the deep analysis … Try to make more precise and better and more v2 to v3 questions. But organize like: Part 1 Critical => up to 5 questions; Part 2 Important => all others, maybe even 20; Part 3 Plus the diff between new files roadmap_en.html / presentation_en.html and actual demo, in the form of questions; Part 4 very optional — UX materials and questions … Include prompt for another AI agent in Part 4. Go.
```

## Turn 8 — (Alfa/Beta scopes; scaffold demo, Alfa default)

```
=> Go. One more thing. I noticed there are actually two scopes of questions related to demo from design v2, v3.
Version Alfa: only critical part of application, similar to Defender, with look and feel of Walrus, similar to ELK, Datadog with capacities but with blockchain domain.
Version Beta: Version Alfa, "but please add two files very big and important: roadmap_en.html / presentation_en.html"
… So we focus on: a) document … Version Alfa / Version Beta b) if possible adjust v2 to v3 questions Part 4 with this context c) … d) then you may "go — scaffold the demo" BUT VERY IMPORTANT - WITH VERSION ALFA BY DEFAULT. include it in script.
… a) give up to 1 min to ask 1-2 clarifying questions b) execute … "go — scaffold the demo" WITH VERSION ALFA BY DEFAULT: generated demo / live locally / with mocks, adrs, docs, ai context / clickable / with demo to manually go through / possible to deploy on remote server (do not do this … add it to top-level capabilities)
```
**Clarifying answers (Turn 8):** Alfa = focused SOC console + CC* (Beta = + Part-3
breadth); scaffold = CC*-first vertical slice.

## Turn 9 — (fix path; document + do remote deploy; audit log; no questions)

```
1. cd .ignored/fe-demo/demo_designV2_genV2/app … did not work. I think you forgot the absolute path.
2. describe local and remote deployment process in top-level readme.md or a new adjacent readme-deployment.md …
3. deploy on remote using already documented execution. 4. test (CC*) on remote. if not satisfactory increment and do a better deployment script with … versioning of fe delivery …
5. document remote url … 6. after that git push … 7. do not ask questions … document … in .ai-fe-design/ai_internal_audit_log new folder.
8. … we deploy alfa version. you proceed until you finish task … open and verify remote deployment and local deployment. do not ask questions … 9. go, proceed
```

## Turn 10 — (keep trying for unrestricted public access)

```
In the meantime see: /Users/macbook/work/Thorium/.ai-fe-design/input/deploy
You will have some feedback from deployment. if not possible try another method.
Please keep trying. I would really like to see:
a) remote unrestricted public access with live demo with (CC*) path clickable through mocks
b) the newest v2 to v3 questions file pushed
c) the last commit pushed to git origin to indicate only precisely prominently the url of your latest deployment that you verified
try better. you can spawn new sub agents or burn too much token. or change model to save tokens … be smart. deliver.
```

## Turn 11 — (precise: v1 + v2 verifiable deployments; archive prompts)

```
I will even be more precise:
a) as soon as you have deployed verifiable (… you open … and confirm what you see on that remote page and confirm it with internal (CC*) requirements … IE. REAL VERSION ALFA FOR MVP OR MOCKUP. … document it. log audit. commit. and push. And make sure the latest v2 to v3 questions are pushed … And make sure the last commit just contain "deployment success : url <with life URL>" …
Let's call this … verifiable deployment with comit deployment pushed to origin as a last commit. with MORE OR LESS MVP v1 deployment.
b) when you pushed you may commit your work or save session
c) you proceed with v2 of deployment: i) you have MVP deployment … ii) you work on your internal processes so that you can improve the proximity of the requirements for hackathon and ai docs and (CC*) requirements. iii) if you have a version that has SUFFICIENTLY closer requirements … you do a v2 second deployment. … only have v1 and v2 remote deployments. Document both remote v1 and v2 remote urls in latest commit in a prominent place. push to git remote.
iv) … now document all these prompts to: /Users/macbook/work/Thorium/.ai-fe-design/prompts/init verbatim ; /Users/macbook/work/Thorium/.ai-fe-design/input/deploy and push … finish your work. Good work
```

**Outcome (Turns 9–11):** local demo verified; remote GitHub Pages blocked (private
repo); **two live public Cloudflare-tunnel deployments** — v1
`roller-flag-smtp-landscape.trycloudflare.com`, v2 (improved)
`survival-montana-duration-rachel.trycloudflare.com`. FE delivery versioned v1
(gh-pages) / v2 (Actions) / v3 (Cloudflare tunnel).

## Turn 12 — (1-min explainer; remote first)
```
ok, so 1 min of read explanation how can I and my friend open it - first focus on remote deployment
```

## Turn 13 — (can't reach URL; redeploy until it works)
```
now make the v3 design from v2 to v3 answers: [image] ===
I do not think it went great. See: input/deploy/Zrzut ekranu 2026-06-19 o 20.28.55.png
I cannot reach the url that you pointed to me that should be accessible and should meet the initial requirements. it does not look good.
proceed until you understand, make new deployments. do not ask until you reach that goal
```
**Root cause found:** the user's router DNS (192.168.0.1) doesn't resolve
`*.trycloudflare.com` (ERR_NAME_NOT_RESOLVED). Earlier checks used 1.1.1.1, masking
it. **Fix:** ngrok (resolves on the router) + IP/LAN URLs (no DNS). Also generated
`fe_design_v3.md` (from adopted assumptions, since answers weren't provided yet).

## Turn 14 — (archive vX; build answers-driven vX+1; ADRs/audit/v3→v4/prompts)
```
1) the existing deployment last (v1 or v2, let's call it vX) a) archive b) make sure it is the last commit with only this note c) make sure that the links to each deployment - here vX remain after the next deployment. … the next agent can do this work again. or drop hints in git.
2) Now, let's do version vX+1. We have a new file: input/answers.md … treat them the most important things.
A) answers.md => must-have, the first principle … follow regardless
B) (CC*) Demo requirements … in the context of A)
C) the previous docs … the SUI hackathon contract, the existing code base - follow optional. … Always follow in the context of A) and then B).
a) doing the local deployment of vX+1 … b) improving it … careful with tokens and max 1-2 iterations c) … it is called vX+1.
i) make a decision ii) write adr.md, explain choice and alternatives iii) … add an audit log of these adr.md decisions. And prepare CAREFULLY the v3 to v4 questions and answers. … max 25-50% length of previos v2 to v3 … and prompts iv) document these prompts in /init/ prompts folder d) version vX+1 is deployed to origin … a remote deployment url is visible in the last commit.
MOST IMPORTANT: 1) directly follow deployment of vX and vX+1 … 2) max 3 deployments: vX, vX+1, vX+2, but two are prefered 3) must at least deploy one next version that follows A),B),C) 4) must verbatim document this chat and these exactly words 5) v3 to v4 questions … max 25%-50% … 6) push all your commits 7) y
```

## Turn 15 — (1-min summary + repeatable runbook for future agents)
```
7) you must summarize output at max 1 min read
+ one more thing. make sure once I have answers from v3 to v4 you can follow the next deployment and follow exactly the previous steps. I expect it to be listed very detailed like a step of previous execution and that a new agent codex / claude / antigravity will know how to perform the deployment from new iterations of answers eg. from v5 to v6 in future. the same steps are documented.
Please follow the work
```
**Outcome (Turns 14–15):** vX (v2) archived (LAN-reachable); **vX+1** built from
`answers.md` (left-rail SOC + Beta-as-mock surfaces + incident tree + onboarding +
Walrus decrypt + K8s preview + WS markers; ADR-0008) and **deployed live** at
`https://4ae4-213-134-178-35.ngrok-free.app`. Added `delivery/ITERATION-RUNBOOK.md`
(repeatable vN→vN+1 steps) + `questions_v3_to_v4_qa.md` (concise) +
`ai_internal_audit_log` updates.

## Turn 16 — (CR-1 round: address code review; 2 deployments; short+long transition Q&A)
```
that is great. My see the output of the other code review concerns documented in:
/Users/macbook/work/Thorium/.ai-fe-design/input/cr/cr-1.md
please follow this code review remarks. ambiguities and things to consider output in v3 to v4 or v4 to v5 (… vXX->vYY transition … with a vXX->vYY transition questions.md file that the user will answer at the end …)
Now, in this iteration we will do two deployments:
a) vXX->vYY transition with all these ambiguities … to vXX->vYY transition questions.md file
b) vXX->vYY+1 deployment as allowing you to experiment with other improvements
but keep in this iteration the max amount of deployments 2. and document everything. and make deployments prominent
vXX->vYY transition CORE RULES:
A) the same as in the previous chat … A) input/answers.md => must-have, first principle … B) (CC*) Demo requirements … C) previous docs / SUI hackathon contract / existing code base - optional, decide …
B) the new context … input/cr/cr-1.md all these ambiguities must be addressed and some … document in adr.md. some not … put into … vXX->vYY transition questions.md
… you do not ask me anything … Any ambiguity is put ultimately in a longer vXX->vYY transition questions.md file. The shorter one may contain a particular ambiguity or not based on relevance
Document verbatim all this conversation in init folder
The output of this command: a) no clarifying questions b) a few deployments c) exactly one document vXX->vYY transition questions.md file in two versions: i) shorter ii) as long as needed to be precise
I expect you to analyze it very carefully and spend 10-25 min …
```
**Outcome (Turn 16):** read CR-1 (Sonnet 4.6). Split remarks → **fixed now** (ADR-0009,
vYY build): adapter seam (`lib/adapter.ts`), WS markers, NOT-OK logs panel, incident-
tree highlight, per-row Walrus real fetch+spinner, realistic invite token, reactive
`connectCmd`, `onDestroy` cleanup, MSSP tenant cycle, AI-agent (Claude Code) modal.
**Experiment** (vYY+1): ⌘K command palette. **Two deployments:** vYY (CR-fix, LAN
:5174) + vYY+1 (ngrok `https://6b3e-213-134-178-35.ngrok-free.app`). Ambiguities → two
transition Q&A files: `questions_v3_to_v4_qa.md` (SHORT) + `_LONG.md` (exhaustive,
P1–P6 + all CR items).

## Turn 17 — THE FINAL ITERATION (append-only LONG Q&A; no new deploy)
```
Now … 1) treat last deployment as final 2) the SHORT transition Q&A as FINAL (don't care this iteration) 3) we only care about the LONG qaa document … APPEND ONLY … only append your new concerns.
a) append CONTENT below b) push the long qaa with appended content c) document /init verbatim
append ALL concerns from cr-2.md (verbatim summary: Part 1 CR-1 quality, Part 2 new code-quality, Part 3 missed answers.md intentions, Part 4 UI interaction gaps, Part 7 must-preserve).
CONTENT: 1) confirm priority rule A) answers.md B) CC* C) prior docs/contract/code 2) check CC* definition matches initial input/last demo/previous answers; if not ask 5-15 Qs 3) Alfa/Beta scope precisely clarified? 4) is last deployment fit for demo tomorrow? what to improve 5) UX & UI interaction quality 6) mobile/responsive/good-looking/advanced enough 7) mock backend scope familiar to end user? secure & configurable enough for tomorrow's integration? 5-15 Qs 8) README & audit & namings ok 9) can they locally generate frontend, similar to history 10) colleague <1 min find: a) all previous remote deployments b) generate new FE from design (similar?) c) read skills/procedures <1min, AI-friendly d) audit/logs/quality enough e) alignment with vision, best deployment, explain in own words
8) output what was achieved 9) output the prompt for the colleague: a) demo last deployment link b) short qaa c) the long qaa WITH APPENDED CONTENT (15-60min fill) d) document audit/deployments/verbatim into /init e) git push everything f) don't ask, work to finish, incremental steps so a new agent can resume
Call this PROMPT: THE FINAL ITERATION. Output steps into .ai-fe-design/FINAL-ITERATION-STEPS/ … g) git push each completed step h) at end output the colleague prompt (9a/b/c). make sure cr-2.md remarks not lost in the long qaa.
```
**Outcome (Turn 17):** read `input/cr/cr-2.md` fully; appended every finding (G/H/I/J/K/
L2/M) + the CONTENT items 1–10 (Part N) to `questions_v3_to_v4_qa_LONG.md` (append-only);
wrote `FINAL-ITERATION-STEPS/00–04` (plan, CR-2-preserved, content, assessment, colleague
prompt); no new deployment (vYY+1 final, `https://6b3e-213-134-178-35.ngrok-free.app`);
pushed each step.

## Turn 18 — CR-3 round (two reviews; longest appended Q&A; doc hygiene)
```
view: 1) input/cr/cr-3-claude-sonnet-4-6.md + cr-3-opus-4-8.md (MOST IMPORTANT INPUT).
2) questions_v4_to_v5_qa_LONG.md as last most important vision (contemplatory only).
3) my opinion on last DDD deployment + alignment with 1) and 2).
4) output to NEW file questions_v5_to_v6_qa_LONG.md — the longest appended qaa — that makes
   ALL doubts in the two cr-3 files very clear; the vision file is contemplatory (don't act);
   document train of thought in skills/prompts/audit. Also a NEW unique section: analysis of
   improvements between previous important deployments (3-5).
3) git push audit/logs/deployments to experimental-aw-fe-v3 (new branch origin). Announce in
   chat + latest commit. Ensure questions_v4_to_v5_qa_LONG.md is the ultimate RFI for vision.
   Don't ask; output all doubts in the longest appended qaa. Output the colleague prompt.
```
**Outcome (Turn 18):** read both CR-3 reviews; wrote `questions_v5_to_v6_qa_LONG.md`
(stated-but-unlanded answers, /init mismatches, CR-2-not-carried, dead code, live-backend,
CC*/scope/brand, the deployment-improvement analysis, consolidated decisions D0–D15);
fixed stale `AGENTS.md` + RUNBOOK; recorded my opinion in
`prompts/init/cr3-understanding-and-opinion.md`. No new deployment (DDD remains live).
