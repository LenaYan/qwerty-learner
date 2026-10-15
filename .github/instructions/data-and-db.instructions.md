---
applyTo: 'src/resources/dictionary.ts,public/dicts/**,src/utils/db/**'
---

# Dictionaries and local persistence

## Dictionaries

- Registry `length` must equal the JSON entry count — chapter count derives from it (H3).
  After any change run `node .gitconfig/copilot/tools/check-dict-registry.mjs`; fix with
  `node scripts/update-dict-size.js`.
- Dictionary ids are referenced by users' stored progress. Never rename or delete an id
  without asking.
- For a full add/update, route to `/agent 20-codegen-dict-onboard`.

## Dexie (`src/utils/db/**`)

- Load `.gitconfig/copilot/domains/common_domains/db-schema.md`.
- Schema change = new `version(N+1)` listing all tables; never edit an older block (H4).
- There is no server copy of user data. A broken migration is unrecoverable for the user.
