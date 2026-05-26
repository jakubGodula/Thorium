# Thorium — Project Instructions

## Read this first

**Project documentation lives in `.ai/`.** Open **`.ai/README.md`** before doing any work — it's the map of the directory and tells you what each file is authoritative for. Then read `.ai/context.md` (architectural ground truth) and `.ai/detailed-roadmap.md` (active week's tasks). All other `.ai/*.md` files have self-orienting headers and can be entered directly.

## Node Version

This project requires Node **22.12+** (managed via nvm). A `.nvmrc` is present at the repo root.

```sh
nvm use        # picks up .nvmrc automatically
```

## Project Structure

- **Root (`/`)** — main SvelteKit app (primary codebase)
- **`my-app/`** — scaffolded SvelteKit sub-project (separate `package.json`, its own `node_modules`)
- **`agent/`** — agent-related code
- **`src/`** — root app source
- **`static/`** — static assets

## Running the Root App

```sh
nvm use
bun install
bun run dev          # dev server (Vite) at http://localhost:5173
bun run build        # production build
bun run preview      # preview production build
bun run check        # type-check with svelte-check
bun run lint         # prettier + eslint
bun run format       # auto-format
```

## Running `my-app`

```sh
cd my-app
bun install
bun run dev          # dev server at http://localhost:5173
```

> **Package manager: `bun`.** Never use `npm`, `npx`, `pnpm`, or `yarn`. `npx <x>` → `bunx <x>`; `npm ci` → `bun install --frozen-lockfile`. See `.ai/context.md` §12.

## Key Dependencies

- SvelteKit `^2.57`, Svelte `^5`
- Vite `^8`
- TypeScript `^6`
- `@mysten/sui` — Sui blockchain wallet integration
