---
applyTo: 'src/pages/Typing/**,src/utils/spacedRepetition.ts,src/utils/db/review-state.ts,src/hooks/usePronunciation.ts,src/components/YouglishLink/**'
---

# Typing flow and memory mechanisms

These files implement retrieval practice, study/test pronunciation timing, end-of-chapter
retest, and spaced repetition.

Before editing:

1. Load `.gitconfig/copilot/domains/common_domains/memory-mechanisms.md` and name the memory
   mechanism the change acts on (hard rule H1).
2. Nothing new may reach the user **before** they finish spelling a practised word — no audio,
   spelling hint, example, or video (H2). First-encounter words are the only exception, via
   `useIsFirstEncounter`.
3. Thresholds (`SLOW_RATIO_TO_MEDIAN`, `SLOW_FLOOR_MS`, `LEECH_THRESHOLD`, the `1.6` baseline
   multiplier, interval constants) carry rationale in their comments. Changing one requires
   stating the evidence in the commit body.
4. The retest word list is intentionally unshuffled; do not wire it to the chapter-shuffle setting.

After editing, run `/agent 30-quality-memory-review` on the diff.
