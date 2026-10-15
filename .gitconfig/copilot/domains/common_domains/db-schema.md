# Local database (Dexie / IndexedDB)

Two databases. Neither has a server copy: a broken migration loses user history permanently.

| DB             | Defined at                               | Tables                                                                                                             |
| -------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `RecordDB`     | `src/utils/db/index.ts:12-45`            | `wordRecords`, `chapterRecords`, `reviewRecords`, `revisionDictRecords`, `revisionWordRecords`, `wordReviewStates` |
| Repeater audio | `src/pages/Repeater/audioStore.ts:30-31` | `audio`, `transcripts`                                                                                             |

Current `RecordDB` version: **4** (`wordReviewStates: '++id,&word,dueTimestamp'`).

## Rules

- Schema change = append `this.version(N+1).stores({...})` listing **all** tables. Never
  edit a previous version block. Use `.upgrade(tx => …)` when existing rows need rewriting.
- `wordReviewStates.word` is unique (`&word`) and keyed per word, not per dictionary. Sessions
  intersect it with the current dictionary at query time — keep it that way.
- Record classes live in `src/utils/db/record.ts`; `mapToClass` is wired in `index.ts`.
- Local-date logic uses `localDateKey()` (`index.ts`), never UTC — the daily quota must reset
  at the user's midnight.
- Export/import goes through `src/utils/db/data-export.ts` (`dexie-export-import`). A new table
  must be checked against export/import round-trip.

## Verifying a schema change

No automated tests exist. Minimum manual check: run `yarn dev` on a browser profile that
already holds version-N data, load the app, confirm in DevTools → Application → IndexedDB
that the version bumped and old rows survived.
