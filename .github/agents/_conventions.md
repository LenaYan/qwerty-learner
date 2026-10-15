# Agent conventions

## Files

- One file per agent: `.github/agents/<layer>-<name>.agent.md`, flat (Copilot does not
  recurse into subdirectories). `_`-prefixed files are documentation, not agents.
- Layers: `20-codegen`, `30-quality`. Add `40-testing`, `50-analysis`, etc. only when an agent
  of that role exists.

## Frontmatter

```yaml
---
name: <exactly the filename stem>
description: <what it does, when to use it, and when not to — one paragraph>
tools: ['read', 'search', ...]
---
```

- `name` must be unique and equal the filename stem.
- `tools` is least-privilege. Review/audit agents never get `edit`.

## Body

Every agent states, in this order: **Inputs**, **Load** (which contracts, by path — never the
whole contracts directory), **Procedure**, **Output** (fixed shape), **Stop conditions**.

## Admission

An agent is added only if it has a cheap verification loop the agent itself runs (a checker
script, tsc, eslint, a diff review). Without one, write a contract or a path instruction instead.
Register it in `_index.md` in the same change, then run
`bash .gitconfig/copilot/validate-config.sh`.

## Side effects

Agents never commit, push, deploy, or call external services. Those stay with the human.
