# Data pipeline

## Shapes

| Data                 | Location                                        | Shape                                                                                       | Keyed by                 |
| -------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------- | ------------------------ |
| Dictionary           | `public/dicts/<name>.json`                      | `[{ name, trans: string[], usphone, ukphone }]`                                             | dictionary               |
| Dictionary registry  | `src/resources/dictionary.ts`                   | `DictionaryResource[]` grouped by category; `url`, `length`, `language`, `languageCategory` | dictionary id            |
| Word details         | `public/word-details/words/<encoded word>.json` | examples, phrases, definitions, mnemonics                                                   | **word**, not dictionary |
| Word-details index   | `public/word-details/index.json`                | list of covered words; frontend fetches a detail file only if listed                        | —                        |
| Annotation side file | `scripts/data/dict-annotations.json`            | raw `【记忆】【搭配】…` blocks stripped from `trans`                                        | word                     |

Only `words/` and `index.json` under `public/word-details/` are committed (`.gitignore`).
Both `public/dicts` and `public/word-details` are excluded from Prettier.

## Scripts (`scripts/`)

All are idempotent. Read the file header before running; it holds the authoritative usage.

| Script                                   | Purpose                                                              | Preconditions / flags                                                                            |
| ---------------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `build-nz-year9-dict.mjs`                | Year 9 dictionary from `scripts/data/nz-year9-vocabulary.json`       | none                                                                                             |
| `build-nz-k12-dicts.mjs`                 | Year 10 dictionary sliced from COCA frequency list                   | none                                                                                             |
| `gen-word-details.mjs`                   | Examples (Tatoeba, ollama fallback) + phrases, zh via ollama         | local ollama (`qwen2.5:14b`) + Tatoeba corpus; `--dict --chapters --words --force --concurrency` |
| `build-word-notes.mjs`                   | Definitions, mnemonics, synonyms/antonyms, collocations into details | detail files exist; reads dicts **and** `dict-annotations.json`                                  |
| `normalise-dict-trans.mjs`               | Unify zh `trans` format across dictionaries                          | `--dry` to preview; writes `dict-annotations.json` before stripping                              |
| `clean-word-details-zh.mjs`              | Strip list-number prefixes from zh translations                      | `--dry-run`                                                                                      |
| `build-word-index.mjs`                   | Migrate legacy dict+chapter details to per-word; rebuild index       | normally not needed                                                                              |
| `word-details-store.mjs`                 | Shared storage layer (library, not a CLI)                            | —                                                                                                |
| `lib/trans-normalise.mjs`                | Shared normalisation logic                                           | —                                                                                                |
| `analyse-retrieval-latency.mjs`          | Offline analysis: first-keystroke vs inter-letter latency            | exported record file as argument                                                                 |
| `update-dict-size.js`                    | Rewrite registry `length` values from JSON counts                    | CommonJS; edits `src/resources/dictionary.ts` in place                                           |
| `pre-check.sh` / `install.sh` (+ `.ps1`) | End-user environment setup                                           | —                                                                                                |

## Procedures

**Add a dictionary**

1. Place JSON in `public/dicts/`, matching the shape above.
2. Register in `src/resources/dictionary.ts` under the right category.
3. `node scripts/update-dict-size.js` (or set `length` by hand).
4. `node .gitconfig/copilot/tools/check-dict-registry.mjs` → must print `OK`.
5. If the gloss is English by design, confirm the English-gloss detector
   (`scripts/lib/trans-normalise.mjs:307`) classifies it as English — run
   `node scripts/normalise-dict-trans.mjs --dry` and check the new file is not rewritten.

**Regenerate notes after normalisation**
`normalise-dict-trans.mjs` → confirm `scripts/data/dict-annotations.json` grew or held →
`build-word-notes.mjs` → spot-check that mnemonic counts did not drop to zero.

**Unregistered files** (as of 2026-10-14, `--orphans`): `ChuZhongluan_2_T`,
`GaoZhongluan_2_T`, `IELTSLiuHongbo538`, `Node-fs`, `Node-path`, `chinese_test`,
`japanese_test`. Unknown whether intentional — ask before deleting or registering.
