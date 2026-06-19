# Original prompt (verbatim)

> Saved verbatim per instruction ("the folder with this prompt — yes! Save this
> prompt verbatim"). This is the exact instruction that generated `fe_design_v1.md`
> and `questions_v1_to_v2_qa.md`. The original short source also lives at
> [`input/prompt.txt`](./input/prompt.txt); the requirements at
> [`input/conversation.txt`](./input/conversation.txt).

---

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
- You will commit these changes directly after user’s prompt
- The commit will contain a logic for a flow from the user/ another dev/ another agent for a new named: .ai-fe-design:
- A) it contains fe_design_v1.md of a very specific as specific as possible design of thorium frontend. Also maybe suggest next steps eg using claude design or a few prompts another user may use
- B) it contains questions_v1_to_v2_qa.md with initial instructions for user having to answer these inline in .md file. Be specific which commands go run to go and use the flow ie:
- B1) user opens project on a new branch name, checks out
- B2) user explicitly in named: .ai-fe-design sees: readme.md (he knows he needs to fill in v1 to v2 answers), the v1 initial design, the folder for inputs, the folder with this prompt (yes! Save this prompt verbatim)
- The user uses antygravity or codez or claude code
- B3) the user’s ai agents know what to do to perform:
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

---

## Follow-up instruction (verbatim)

```
please remember to commit and push directly after you finish your work from
commandline. do not rebase already pushed commit. only push as an end goal -
after you finish all these. do not ask me for anything. just push. leave
questions to v1 to v2 file. push to git after analysis
```
