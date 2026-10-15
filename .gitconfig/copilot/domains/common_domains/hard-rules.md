# Hard rules

Non-negotiable. Each rule states the failure it prevents. Product-direction rules
(rejected features, pronunciation source, YouGlish terms) live in `CLAUDE.md`; they are
not repeated here.

| #   | Rule                                                                                                                                                                                     | Prevents                                                               |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| H1  | Every typing-flow change names the memory mechanism it acts on before any code is written (see `memory-mechanisms.md`)                                                                   | Changes that feel smoother but flatten retrieval difficulty            |
| H2  | Never move answer exposure (audio, spelling, examples, video) to **before** the user finishes spelling a practised word                                                                  | Degrading cued recall into dictation/copying                           |
| H3  | Dictionary `length` in `src/resources/dictionary.ts` equals the JSON entry count; verify with `node .gitconfig/copilot/tools/check-dict-registry.mjs`                                    | Missing or empty chapters (chapter count derives from `length`)        |
| H4  | Dexie schema changes add `version(N+1)`; never edit an existing `version(...)` block                                                                                                     | Breaking upgrade for every existing user's IndexedDB                   |
| H5  | Static data URLs (`/dicts/*`, `/word-details/*`) go through the version-suffix helper in `src/utils/index.ts:16`                                                                         | Cloudflare serving stale data for 30 days (see `known-pitfalls.md` P2) |
| H6  | `normalise-dict-trans.mjs` and `build-word-notes.mjs` change together, never one alone                                                                                                   | Mnemonics/collocations silently dropping to zero                       |
| H7  | Any "unify to Chinese" processing excludes English-gloss dictionaries (`4000_Essential_English_Words`, `SATen`, `word_roots1`, …); the detector is `scripts/lib/trans-normalise.mjs:307` | Destroying deliberately English definitions                            |
| H8  | Never deploy without confirming `build/` is non-empty and fresh; prefer `make deploy-dry` first                                                                                          | `rsync --delete` wiping the server after a silent empty build          |
| H9  | Stage files by explicit path only; never `git add .` / `-A` / `-u` / `commit -a`                                                                                                         | Committing another session's uncommitted work                          |
| H10 | `Makefile` is gitignored (contains server details); never commit it, never print its host/credentials into published text                                                                | Leaking deployment infrastructure                                      |
