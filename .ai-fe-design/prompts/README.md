# `prompts/` — prompt & context archive

Verbatim prompts and the decision/context record for the Thorium XDR frontend
design work, so any future agent or human can reconstruct *why* the specs look the
way they do.

```
prompts/
├── README.md          ← this file
└── init/              ← THE founding conversation (design v1 → v2 + demo generator)
    ├── README.md      ← index + summary of the session
    ├── conversation.md← every USER prompt, verbatim, in order (+ attachment pointers)
    └── decision-log.md← structured log of decisions, Q&A answers, and assumptions
```

Convention: each distinct working session gets its own subfolder (`init`, then
future ones). Prompts are saved **verbatim**; tool outputs/images are referenced,
not duplicated (the images live in [`../input/`](../input/)).
