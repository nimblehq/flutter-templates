#!/usr/bin/env bash
# Opus token-tracked benchmark teardown: collect outputs, remove worktrees, restore memory.
# (Note: token extraction needs the worktree's encoded path, which only depends on the
# absolute path — not on the worktree still existing — but the JSONL files live in
# ~/.claude/projects/ so they're untouched by removing worktrees. Safe to run after verify.)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

CASES=(baseline perms apostrophe longname norename)
PARENT="$(dirname "$REPO_ROOT")"
MEMORY_DIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-flutter-templates/memory"
MEMORY_BAK="${MEMORY_DIR}.bench-bak"

mkdir -p output/m_runs_opus_tokens
echo "Collecting outputs into $REPO_ROOT/output/m_runs_opus_tokens/"
echo ""

for CASE in "${CASES[@]}"; do
  WT="$PARENT/bench-opus-${CASE}"
  SRC="$WT/output/m_runs_opus_tokens/${CASE}"
  DST="$REPO_ROOT/output/m_runs_opus_tokens/${CASE}"

  if [ -d "$SRC" ] && [ "$(ls -A "$SRC" 2>/dev/null)" ]; then
    mkdir -p "$(dirname "$DST")"
    rm -rf "$DST"
    cp -R "$SRC" "$DST"
    FILES=$(find "$DST" -type f | wc -l | tr -d ' ')
    echo "✓ ${CASE} → $DST ($FILES files)"
  else
    echo "⚠ ${CASE} produced no output at $SRC — skipping."
  fi
done

echo ""

for CASE in "${CASES[@]}"; do
  WT="$PARENT/bench-opus-${CASE}"
  if [ -d "$WT" ]; then
    git worktree remove --force "$WT" 2>/dev/null && echo "✓ Removed worktree: $WT" || \
      (rm -rf "$WT" && echo "✓ Force-removed dir: $WT")
  fi
done

git worktree prune 2>/dev/null || true

echo ""

if [ -d "$MEMORY_BAK" ]; then
  if [ -d "$MEMORY_DIR" ]; then
    mv "$MEMORY_DIR" "${MEMORY_DIR}.bench-during-opus"
  fi
  mv "$MEMORY_BAK" "$MEMORY_DIR"
  echo "✓ Memory dir restored"
fi

echo ""
echo "=========================================="
echo "  TEARDOWN COMPLETE"
echo "=========================================="
ls -la output/m_runs_opus_tokens/ 2>/dev/null
echo ""
echo "Next: bash scripts/benchmark/verify-opus-tokens.sh"
