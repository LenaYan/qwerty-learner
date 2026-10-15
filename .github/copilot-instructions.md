# Copilot instructions — qwerty-learner

**Product rules live in `CLAUDE.md`** at the repo root (auto-loaded by Copilot CLI and Claude
Code). It is the single canonical source for: the cognitive-psychology basis of every feature,
rejected directions, the three implemented memory mechanisms, the data pipeline overview, and
project conventions. Do not restate it here or anywhere under `.github/`; extend it there.

This file adds only what Copilot needs on top: where the deeper contracts are, how to verify,
and which agent to route to.

## Hard rules

`.gitconfig/copilot/domains/common_domains/hard-rules.md` (H1–H10). Read it before any commit,
deploy, Dexie schema change, or dictionary change.

## Load-trigger map

Contracts live in `.gitconfig/copilot/domains/common_domains/`. Load one only when its trigger
matches; never bulk-load the directory.

| Task                                                                            | Load                      |
| ------------------------------------------------------------------------------- | ------------------------- |
| Typing flow, pronunciation timing, result screen, SRS, any new learning feature | `memory-mechanisms.md`    |
| Dictionary JSON, registry, word details, anything in `scripts/`                 | `data-pipeline.md`        |
| `src/utils/db/**`, Dexie tables, persisted record shapes                        | `db-schema.md`            |
| Verifying, building, committing, deploying                                      | `operational-playbook.md` |
| Build/deploy/cache/analytics bugs, or editing a file a pitfall names            | `known-pitfalls.md`       |

## Verification (minimum)

No automated tests exist. Default checks, all green at baseline:

- `npx tsc --noEmit -p .`
- `npx eslint <touched files>`
- `node .gitconfig/copilot/tools/check-dict-registry.mjs` when dictionaries change
- `yarn build` when `vite.config.ts` or dependencies change

UI behaviour can only be checked with `yarn dev` by hand — report it as unverified otherwise.

## Agent routing

Registry: `.github/agents/_index.md`. Conventions: `.github/agents/_conventions.md`.

| Situation                                                           | Route to                                            |
| ------------------------------------------------------------------- | --------------------------------------------------- |
| Diff or proposal touches typing flow / pronunciation / retest / SRS | `/agent 30-quality-memory-review` before committing |
| Add, resize, rename, or recategorise a dictionary                   | `/agent 20-codegen-dict-onboard`                    |
| Anything else                                                       | Main thread                                         |

## Context budget

- Delegate by **shape**: breadth surveys (e.g. "which of the 313 dictionaries have English
  glosses") go to a subagent; a single trace (one bug, one data path) stays on the main thread.
  Do not delegate when the answer is in a known file or takes ≤ 5 tool calls.
- Every delegated prompt states scope bound, return shape, and stop condition.
- `public/dicts/` (313 files) and `public/word-details/words/` (~7k files) are data, not code.
  Never read them wholesale; sample one file or use the registry checker.

## Output placement

| Output                     | Location                                     |
| -------------------------- | -------------------------------------------- |
| User-facing docs           | `docs/`                                      |
| Project rule changes       | `CLAUDE.md` (canonical)                      |
| Contract / pitfall updates | `.gitconfig/copilot/domains/common_domains/` |
| Scratch, plans, handoffs   | session state directory — never committed    |

Do not create markdown files in the repo root.
