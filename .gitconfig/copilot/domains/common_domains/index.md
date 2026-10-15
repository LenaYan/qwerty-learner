# Common domain contracts — index

Load a contract **only** when the task matches its trigger. Never bulk-load this directory.

`CLAUDE.md` at the repo root is the canonical statement of product rules and rejected
directions; it is auto-loaded by Copilot CLI and Claude Code alike. These contracts add
what CLAUDE.md does not carry: code locations, procedures, and earned pitfalls. If a
contract and CLAUDE.md disagree, CLAUDE.md wins and the contract is the bug.

| Contract                                           | Load when                                                                                             |
| -------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| [hard-rules.md](hard-rules.md)                     | Before any commit, deploy, dependency change, or external-service change                              |
| [memory-mechanisms.md](memory-mechanisms.md)       | Touching the typing flow, pronunciation timing, result screen, SRS, or proposing any learning feature |
| [data-pipeline.md](data-pipeline.md)               | Adding/editing a dictionary, word details, or anything under `scripts/`                               |
| [db-schema.md](db-schema.md)                       | Touching `src/utils/db/**`, Dexie tables, or persisted record shapes                                  |
| [operational-playbook.md](operational-playbook.md) | Running verification, building, deploying, or committing                                              |
| [known-pitfalls.md](known-pitfalls.md)             | Debugging build/deploy/cache/analytics issues, or editing the files those pitfalls name               |
