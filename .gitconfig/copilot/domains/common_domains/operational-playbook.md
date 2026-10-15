# Operational playbook

Read at the moment you need it; not part of the always-loaded index.

## Verification commands

Baseline measured 2026-10-14 on a clean tree after `yarn install --frozen-lockfile`: all green.

| Check               | Command                                                 | Time  | Notes                                                                                             |
| ------------------- | ------------------------------------------------------- | ----- | ------------------------------------------------------------------------------------------------- |
| Type-check          | `npx tsc --noEmit -p .`                                 | ~10 s | No `typecheck` script in `package.json`; use this                                                 |
| Lint                | `npx eslint <paths>` (or `yarn lint` for all)           | ~10 s | ESLint 8 skips dot-directories, so `.github/` and `.gitconfig/` are not linted                    |
| Build               | `yarn build`                                            | ~12 s | Chunk-size warnings are pre-existing and expected. Confirm `build/index.html` exists (pitfall P1) |
| Dictionary registry | `node .gitconfig/copilot/tools/check-dict-registry.mjs` | < 1 s | `--orphans` lists unregistered files                                                              |
| Copilot config      | `bash .gitconfig/copilot/validate-config.sh`            | < 1 s | Structural drift of this config                                                                   |
| Tests               | —                                                       | —     | None exist. `yarn test` is a stub that prints "No tests"                                          |

Smallest sufficient set by change type:

| Change                                             | Run                                                                                                      |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `src/**` logic                                     | tsc + eslint on touched files                                                                            |
| `src/resources/dictionary.ts` or `public/dicts/**` | registry check + tsc                                                                                     |
| `scripts/*.mjs`                                    | `node --check <file>` + eslint on the file + the script's own `--dry`/`--dry-run` if it has one          |
| `vite.config.ts`, dependencies                     | full build                                                                                               |
| `.github/**`, `.gitconfig/copilot/**`              | config validator                                                                                         |
| UI behaviour                                       | `yarn dev` and exercise the flow manually — say so explicitly in the report, it cannot be automated here |

## Commit

- `.husky/pre-commit` runs lint-staged (Prettier on staged `src/**`), then `eslint . --fix` and
  `prettier --write .` on the whole tree, then the Copilot config checks. Expect unrelated
  working-tree reformatting; it is not staged (pitfall P7).
- Commit messages in `git log` follow `type(scope): summary` with a body explaining _why_.

## Deploy

- `make deploy` = `yarn build` then `rsync -avz --delete build/` to the server. The `Makefile`
  is gitignored and exists only on the maintainer's machine.
- Always `make deploy-dry` first when unsure. Never deploy from an agent.
- After deploy, static data is cache-busted by commit hash (pitfall P2); a deploy from a
  dirty tree reuses the last commit's hash and may serve stale data.
