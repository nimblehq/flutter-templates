#!/usr/bin/env bash
# Multi-model benchmark teardown: collect outputs, remove worktrees, restore memory.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

MODELS=(haiku sonnet)
CASES=(perms apostrophe longname norename)
PARENT="$(dirname "$REPO_ROOT")"
MEMORY_DIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-flutter-templates/memory"
MEMORY_BAK="${MEMORY_DIR}.bench-bak"

mkdir -p output/m_runs_models
echo "Collecting outputs into $REPO_ROOT/output/m_runs_models/"
echo ""

for MODEL in "${MODELS[@]}"; do
  for CASE in "${CASES[@]}"; do
    WT="$PARENT/bench-models-${MODEL}-${CASE}"
    SRC="$WT/output/m_runs_models/${MODEL}/${CASE}"
    DST="$REPO_ROOT/output/m_runs_models/${MODEL}/${CASE}"

    if [ -d "$SRC" ] && [ "$(ls -A "$SRC" 2>/dev/null)" ]; then
      mkdir -p "$(dirname "$DST")"
      rm -rf "$DST"
      cp -R "$SRC" "$DST"
      FILES=$(find "$DST" -type f | wc -l | tr -d ' ')
      echo "✓ ${MODEL}/${CASE} → $DST ($FILES files)"
    else
      echo "⚠ ${MODEL}/${CASE} produced no output at $SRC — skipping."
    fi
  done
done

echo ""

for MODEL in "${MODELS[@]}"; do
  for CASE in "${CASES[@]}"; do
    WT="$PARENT/bench-models-${MODEL}-${CASE}"
    if [ -d "$WT" ]; then
      git worktree remove --force "$WT" 2>/dev/null && echo "✓ Removed worktree: $WT" || \
        (rm -rf "$WT" && echo "✓ Force-removed dir: $WT")
    fi
  done
done

git worktree prune 2>/dev/null || true

echo ""

if [ -d "$MEMORY_BAK" ]; then
  if [ -d "$MEMORY_DIR" ]; then
    mv "$MEMORY_DIR" "${MEMORY_DIR}.bench-during-models"
  fi
  mv "$MEMORY_BAK" "$MEMORY_DIR"
  echo "✓ Memory dir restored"
fi

echo ""
echo "=========================================="
echo "  TEARDOWN COMPLETE"
echo "=========================================="
ls -la output/m_runs_models/ 2>/dev/null
echo ""
echo "Next: bash output/verify-models.sh"
