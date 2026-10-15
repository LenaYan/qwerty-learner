# Memory mechanisms — code map and change gate

Why each mechanism exists is in `CLAUDE.md`. This file maps the rationale to code and
gives the checklist a change must pass. Line numbers verified 2026-10-14; re-check with
grep before quoting them.

## Code map

| Mechanism                                                  | Memory principle                                    | Where                                                                                                                                   |
| ---------------------------------------------------------- | --------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Cued recall: Chinese shown, English hidden                 | Retrieval practice                                  | Default `type: 'hideAll'` at `src/store/index.ts:151`; applied in `src/pages/Typing/components/WordPanel/components/Word/index.tsx:292` |
| Study vs test trial pronunciation                          | Encoding vs retrieval; corrective feedback on error | `src/pages/Typing/hooks/useIsFirstEncounter.ts:15`, consumed at `Word/index.tsx:103`                                                    |
| End-of-chapter retest (wrong + hesitant words, unshuffled) | Within-session spaced retrieval                     | `src/pages/Typing/components/ResultScreen/index.tsx:35-36` (`SLOW_RATIO_TO_MEDIAN = 1.6`, `SLOW_FLOOR_MS = 300`)                        |
| SRS scheduling (SM-2 variant, performance-derived grade)   | Spacing effect                                      | `src/utils/spacedRepetition.ts` — `gradeFromPerformance` `:95`, hard threshold `baseline * 1.6` `:112`, `scheduleNext` `:119`           |
| Leech handling (de-prioritise words failed ≥ 8 times)      | Desirable-difficulty boundary                       | `spacedRepetition.ts:49` `LEECH_THRESHOLD`, `:55` `LEECH_COOLOFF_DAYS = 4`, `:68` `isLeech`                                             |
| Review state persistence and daily quota                   | Spacing across days                                 | `src/utils/db/review-state.ts`, table `wordReviewStates` (`src/utils/db/index.ts:38-43`), `src/pages/Typing/hooks/useDueReview.ts`      |
| Post-retrieval context (YouGlish, synonyms on detail card) | Elaboration after retrieval                         | `src/components/YouglishLink/index.tsx`                                                                                                 |

## Change gate

A change to any file above, or any new learning feature, must answer in the PR/commit body:

1. **Mechanism** — which principle does it act on? Name it.
2. **Evidence strength** — citation or "intuition only". Intuition-only changes to the
   typing flow are rejected.
3. **Retrieval timing** — does anything new appear _before_ spelling completes for a
   practised word? If yes, it violates hard rule H2.
4. **Interaction with the three mechanisms** — does it double-count a retrieval
   (e.g. same-day retry both in retest and SRS)? CLAUDE.md assigns same-day retries to
   the retest only.
5. **Silent degradation** — if the change down-ranks or hides words, does the UI say so?
   (Precedent: leech count shown in the review tooltip, commit `d9df46d0`.)

## Open measurement

`scripts/analyse-retrieval-latency.mjs` tests whether first-keystroke latency predicts
forgetting better than inter-letter interval (commit `b21f6f1c` started collecting it).
Until it reports, do not replace the hesitation signal.
