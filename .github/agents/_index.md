# Agent registry

Authoritative list. Every `*.agent.md` in this directory has exactly one row here, and every
row has a file. Enforced by `.gitconfig/copilot/validate-config.sh`.

| Name                       | File                                | Layer   | Writes? | Purpose                                                                                     |
| -------------------------- | ----------------------------------- | ------- | ------- | ------------------------------------------------------------------------------------------- |
| `20-codegen-dict-onboard`  | `20-codegen-dict-onboard.agent.md`  | codegen | yes     | Add/update a dictionary JSON + registry entry, verified by registry checker and tsc         |
| `30-quality-memory-review` | `30-quality-memory-review.agent.md` | quality | no      | Gate typing-flow diffs and learning-feature proposals against the memory-mechanism contract |

## Deliberately not agents

| Candidate              | Why not                                                                                                     |
| ---------------------- | ----------------------------------------------------------------------------------------------------------- |
| Word-detail generation | Needs local ollama + Tatoeba corpus; no cheap verification loop. Run `scripts/gen-word-details.mjs` by hand |
| Test writer            | Repo has no test runner (`package.json` `test` is a stub). Revisit when one is adopted                      |
| Deploy                 | Outside-workspace side effect (`rsync --delete`); stays a human action                                      |
