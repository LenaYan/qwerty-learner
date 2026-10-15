---
applyTo: 'scripts/**'
---

# Data scripts

- Load `.gitconfig/copilot/domains/common_domains/data-pipeline.md` first.
- Every script must stay idempotent: a second run produces zero changes. Provide `--dry` or
  `--dry-run` for anything that rewrites data.
- Start each script with a header comment: purpose, why it exists, data sources, usage lines.
  Existing scripts write this in Chinese; follow the file you are editing.
- `normalise-dict-trans.mjs` strips annotation blocks that `build-word-notes.mjs` consumes via
  `scripts/data/dict-annotations.json`. Change both together or neither (hard rule H6).
- Chinese-unification logic must keep excluding English-gloss dictionaries; the detector is in
  `scripts/lib/trans-normalise.mjs` (H7).
- ESM `.mjs` is linted with `eslint:recommended` under Node env; `update-dict-size.js` is CommonJS.
- Verify with `node --check <file>`, `npx eslint <file>`, and the script's own dry-run mode.
  Do not run `gen-word-details.mjs` unless the user confirms local ollama and the Tatoeba corpus.
