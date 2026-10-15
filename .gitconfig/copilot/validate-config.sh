#!/usr/bin/env bash
# qwerty-learner Copilot config STRUCTURAL validator
# -------------------------------------------------------------
# Objective checks only; every finding is an error.
#
#   1  Agent registry      every .github/agents/*.agent.md has a row in _index.md, and back
#   2  Agent frontmatter   name == filename stem, unique; description and tools present
#   3  Instructions        every .github/instructions/*.instructions.md has applyTo
#   4  Contract registry   every common_domains/*.md is linked from its index.md, and back
#   5  Path references     every backticked repo path in config prose exists; a :N or :N-M
#                          suffix must be within the file's line count
#   6  Agent references    every `/agent X` in config prose resolves to an agent file
#   7  No duplication      no substantive line of CLAUDE.md is copied into .github/
#   8  Script health       tools/*.mjs pass node --check, *.sh pass bash -n, all executable
#
# Modes: (none) or --check — identical; this script never writes.
# Portable to macOS bash 3.2.
#
# Run: bash .gitconfig/copilot/validate-config.sh [--check]
# -------------------------------------------------------------

set -u
case "${1:-}" in
  ''|--check) ;;
  *) echo "usage: $0 [--check]" >&2; exit 2 ;;
esac

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT" || exit 2

AGENTS=.github/agents
INSTR=.github/instructions
DOMAINS=.gitconfig/copilot/domains/common_domains
errors=0
err() { printf '  \033[0;31mERROR\033[0m %s\n' "$*"; errors=$((errors + 1)); }
section() { printf '\033[1m%s\033[0m\n' "$*"; }

frontmatter_field() { # file field
  awk -v f="$2" 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} NR>1{ if (index($0, f":")==1){ sub("^" f ":[ ]*",""); print; exit } }' "$1"
}

config_md_files() {
  {
    echo .github/copilot-instructions.md
    ls $AGENTS/*.md $INSTR/*.md $DOMAINS/*.md 2>/dev/null
  } | sort -u
}

section "1 Agent registry"
for f in $AGENTS/*.agent.md; do
  [ -e "$f" ] || continue
  base=$(basename "$f")
  grep -q "\`$base\`" $AGENTS/_index.md || err "$f has no row in $AGENTS/_index.md"
done
for base in $(grep -oE '`[A-Za-z0-9_-]+\.agent\.md`' $AGENTS/_index.md | tr -d '`' | sort -u); do
  [ -f "$AGENTS/$base" ] || err "_index.md lists $base but the file does not exist"
done

section "2 Agent frontmatter"
seen=""
for f in $AGENTS/*.agent.md; do
  [ -e "$f" ] || continue
  stem=$(basename "$f" .agent.md)
  name=$(frontmatter_field "$f" name)
  [ "$name" = "$stem" ] || err "$f: name '$name' != filename stem '$stem'"
  case " $seen " in *" $name "*) err "$f: duplicate name '$name'" ;; esac
  seen="$seen $name"
  [ -n "$(frontmatter_field "$f" description)" ] || err "$f: missing description"
  [ -n "$(frontmatter_field "$f" tools)" ] || err "$f: missing tools"
done

section "3 Instructions applyTo"
for f in $INSTR/*.instructions.md; do
  [ -e "$f" ] || continue
  [ -n "$(frontmatter_field "$f" applyTo)" ] || err "$f: missing applyTo"
done

section "4 Contract registry"
for f in $DOMAINS/*.md; do
  base=$(basename "$f")
  [ "$base" = index.md ] && continue
  grep -q "($base)" $DOMAINS/index.md || err "$base is not linked from $DOMAINS/index.md"
done
for base in $(grep -oE '\([a-z0-9-]+\.md\)' $DOMAINS/index.md | tr -d '()' | sort -u); do
  [ -f "$DOMAINS/$base" ] || err "index.md links $base but the file does not exist"
done

section "5 Path references"
for f in $(config_md_files); do
  # Backticked tokens that start at a known repo root. Globs and placeholders are skipped.
  grep -oE '`(src|scripts|public|docs|\.github|\.gitconfig|\.husky)/[^` ]+`|`(CLAUDE\.md|vite\.config\.ts|package\.json)(:[0-9-]+)?`' "$f" |
    tr -d '`' | sort -u | while read -r ref; do
      path=${ref%%:*}
      case "$path" in *'*'*|*'<'*|*'…'*) continue ;; esac
      path=${path%/}
      if [ ! -e "$path" ]; then
        echo "$f: \`$ref\` does not exist"
        continue
      fi
      if [ "$ref" != "$path" ] && [ -f "$path" ]; then
        range=${ref#*:}
        last=${range#*-}
        lines=$(wc -l < "$path" | tr -d ' ')
        [ "$last" -le "$lines" ] 2>/dev/null || echo "$f: \`$ref\` beyond end of file ($lines lines)"
      fi
    done
done > /tmp/qwerty-validate-refs.$$
while read -r line; do err "$line"; done < /tmp/qwerty-validate-refs.$$
rm -f /tmp/qwerty-validate-refs.$$

section "6 Agent references"
for f in $(config_md_files); do
  for a in $(grep -oE '`/agent [A-Za-z0-9_-]+`' "$f" | awk '{print $2}' | tr -d '`' | sort -u); do
    [ -f "$AGENTS/$a.agent.md" ] || err "$f references /agent $a, which does not exist"
  done
done

section "7 No duplication of CLAUDE.md"
if [ ! -f CLAUDE.md ]; then
  err "CLAUDE.md missing — it is the canonical rules source this config points to"
else
  dup=$(awk 'length($0) >= 40' CLAUDE.md | sort -u > /tmp/qwerty-claude.$$
        cat .github/copilot-instructions.md $AGENTS/*.md $INSTR/*.md | sort -u | comm -12 /tmp/qwerty-claude.$$ - | head -3
        rm -f /tmp/qwerty-claude.$$)
  [ -z "$dup" ] || err "lines copied from CLAUDE.md into .github/ (extend CLAUDE.md instead): $(echo "$dup" | head -1 | cut -c1-60)…"
fi

section "8 Script health"
for f in .gitconfig/copilot/tools/*.mjs; do
  [ -e "$f" ] || continue
  node --check "$f" 2>/dev/null || err "$f fails node --check"
  [ -x "$f" ] || err "$f is not executable"
done
for f in .gitconfig/copilot/*.sh .gitconfig/copilot/tools/*.sh; do
  [ -e "$f" ] || continue
  bash -n "$f" || err "$f fails bash -n"
  [ -x "$f" ] || err "$f is not executable"
done

echo
if [ "$errors" -gt 0 ]; then
  printf '\033[0;31m%d error(s)\033[0m\n' "$errors"
  exit 1
fi
printf '\033[0;32mOK\033[0m\n'
