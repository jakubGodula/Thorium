# Thorium — Project Instructions

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
npm install
npm run dev          # dev server (Vite) at http://localhost:5173
npm run build        # production build
npm run preview      # preview production build
npm run check        # type-check with svelte-check
npm run lint         # prettier + eslint
npm run format       # auto-format
```

## Running `my-app`

```sh
cd my-app
npm install
npm run dev          # dev server at http://localhost:5173
```

## Key Dependencies

- SvelteKit `^2.57`, Svelte `^5`
- Vite `^8`
- TypeScript `^6`
- `@mysten/sui` — Sui blockchain wallet integration
