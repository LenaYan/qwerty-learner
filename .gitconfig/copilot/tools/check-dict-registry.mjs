#!/usr/bin/env node

/**
 * Verify that every dictionary registered in src/resources/dictionary.ts points at an
 * existing public/dicts/*.json file whose entry count equals the registered `length`.
 *
 * Why: chapter count is derived from `length` (calcChapterCount), so a stale value
 * silently produces missing or empty chapters. scripts/update-dict-size.js can rewrite
 * the numbers, but nothing told you they were wrong.
 *
 * Read-only. Exit 0 = consistent, 1 = mismatch found, 2 = could not run.
 *
 * Run: node .gitconfig/copilot/tools/check-dict-registry.mjs [--orphans]
 *   --orphans  also list public/dicts/*.json files that no registry entry references
 */
import fs from 'node:fs'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..')
const registryPath = path.join(root, 'src/resources/dictionary.ts')
const publicDir = path.join(root, 'public')
const showOrphans = process.argv.includes('--orphans')

let source
try {
  source = fs.readFileSync(registryPath, 'utf8')
} catch (err) {
  console.error(`cannot read ${registryPath}: ${err.message}`)
  process.exit(2)
}

// Pair each `url:` with the next `length:`, the same pairing scripts/update-dict-size.js relies on.
const pattern = /url:\s*'([^']+)'[\s\S]*?length:\s*(\d+)/g
const entries = [...source.matchAll(pattern)].map((m) => ({
  url: m[1],
  length: Number(m[2]),
  line: source.slice(0, m.index).split('\n').length,
}))

if (entries.length === 0) {
  console.error('no url/length pairs found — registry format changed? update this checker.')
  process.exit(2)
}

const problems = []
const referenced = new Set()
const countCache = new Map()

for (const { url, length, line } of entries) {
  const file = path.join(publicDir, url)
  referenced.add(path.resolve(file))
  const where = `src/resources/dictionary.ts:${line}`
  if (!fs.existsSync(file)) {
    problems.push(`${where}  ${url}  file missing`)
    continue
  }
  let actual = countCache.get(file)
  if (actual === undefined) {
    try {
      const data = JSON.parse(fs.readFileSync(file, 'utf8'))
      actual = Array.isArray(data) ? data.length : NaN
    } catch (err) {
      problems.push(`${where}  ${url}  invalid JSON: ${err.message}`)
      continue
    }
    countCache.set(file, actual)
  }
  if (Number.isNaN(actual)) problems.push(`${where}  ${url}  top-level JSON is not an array`)
  else if (actual !== length) problems.push(`${where}  ${url}  registered length ${length}, file has ${actual}`)
}

console.log(`checked ${entries.length} registry entries`)

if (showOrphans) {
  const orphans = fs
    .readdirSync(path.join(publicDir, 'dicts'))
    .filter((f) => f.endsWith('.json'))
    .filter((f) => !referenced.has(path.resolve(publicDir, 'dicts', f)))
  console.log(`unreferenced dict files: ${orphans.length}`)
  for (const f of orphans) console.log(`  public/dicts/${f}`)
}

if (problems.length) {
  console.error(`\n${problems.length} problem(s):`)
  for (const p of problems) console.error(`  ${p}`)
  console.error('\nFix lengths with: node scripts/update-dict-size.js')
  process.exit(1)
}
console.log('OK')
