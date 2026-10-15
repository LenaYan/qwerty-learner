---
name: 20-codegen-dict-onboard
description: Adds or updates a word dictionary in qwerty-learner end to end — places the JSON under public/dicts, registers it in src/resources/dictionary.ts with the correct length and category, and verifies registry consistency and type-check. Use when the user supplies a word list or asks to add, rename, resize, or recategorise a dictionary. Not for word-detail (example sentence) generation.
tools: ['read', 'edit', 'search', 'shell']
---

# Dictionary onboarding

## Inputs

- Source word list (path or pasted data) **or** an existing dictionary id to modify.
- Target category and display name. If either is missing, ask once, offering the existing
  categories found in `src/resources/dictionary.ts`.

## Load

- `.gitconfig/copilot/domains/common_domains/data-pipeline.md` — shapes and the add-a-dictionary procedure.
- `.gitconfig/copilot/domains/common_domains/hard-rules.md` — H3, H6, H7.

## Procedure

1. **Baseline**: run `node .gitconfig/copilot/tools/check-dict-registry.mjs`. If it already
   fails, report the pre-existing failures and continue; do not fix unrelated entries.
2. **Shape the JSON** to `[{ name, trans: string[], usphone, ukphone }]`. Missing phonetics
   become `""`, never invented. Deduplicate by `name` case-insensitively and report the count
   removed.
3. **Gloss language**: if `trans` is Chinese, match the format produced by
   `scripts/lib/trans-normalise.mjs` (preview with `node scripts/normalise-dict-trans.mjs --dry`).
   If English by design, confirm the English-gloss detector (`scripts/lib/trans-normalise.mjs:307`)
   classifies it as English.
4. **Write** `public/dicts/<id>.json`. If a build script produced it, put the generator under
   `scripts/` following the existing `build-nz-*.mjs` pattern (idempotent, header comment
   explaining source and rationale).
5. **Register** in `src/resources/dictionary.ts` next to its category siblings, copying their
   field order. Set `length` via `node scripts/update-dict-size.js`.
6. **Verify** — all must pass:
   - `node .gitconfig/copilot/tools/check-dict-registry.mjs` → `OK`
   - `npx tsc --noEmit -p .` → no new errors versus baseline
   - `npx eslint src/resources/dictionary.ts`

## Output

| Item           | Value                                                         |
| -------------- | ------------------------------------------------------------- |
| Files          | each path + one-line purpose                                  |
| Entries        | final count, duplicates removed, entries with empty phonetics |
| Verification   | each command and its result                                   |
| Open questions | anything assumed                                              |

## Stop conditions

- Never delete or rename an existing dictionary file without explicit confirmation — users'
  progress records reference dictionary ids.
- Never run `gen-word-details.mjs` (needs local ollama + corpus; out of scope).
- Stop after verification; do not commit.
