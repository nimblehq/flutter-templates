#!/usr/bin/env bash
# Cross-model benchmark teardown: collect outputs, remove worktrees, restore memory.
# Run after all 4 model runs are complete.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

MODELS=(haiku sonnet opus codex)
PARENT="$(dirname "$REPO_ROOT")"
MEMORY_DIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-flutter-templates/memory"
MEMORY_BAK="${MEMORY_DIR}.bench-bak"

echo "Collecting outputs from worktrees into $REPO_ROOT/output/m_runs/"
echo ""

mkdir -p output/m_runs

# 1. Copy each worktree's output back to main repo for comparison.
for M in "${MODELS[@]}"; do
  WT="$PARENT/bench-$M"
  SRC="$WT/output/m_runs/$M"
  DST="$REPO_ROOT/output/m_runs/$M"

  if [ -d "$SRC" ] && [ "$(ls -A "$SRC" 2>/dev/null)" ]; then
    rm -rf "$DST"
    cp -R "$SRC" "$DST"
    FILES=$(find "$DST" -type f | wc -l | tr -d ' ')
    echo "✓ $M → $DST ($FILES files)"
  else
    echo "⚠ $M produced no output at $SRC — skipping."
  fi
done

echo ""

# 2. Remove the worktrees.
for M in "${MODELS[@]}"; do
  WT="$PARENT/bench-$M"
  if [ -d "$WT" ]; then
    git worktree remove --force "$WT" 2>/dev/null && echo "✓ Removed worktree: $WT" || \
      (rm -rf "$WT" && echo "✓ Force-removed worktree dir: $WT")
  fi
done

# Prune any stale worktree refs.
git worktree prune 2>/dev/null || true

echo ""

# 3. Restore memory dir.
if [ -d "$MEMORY_BAK" ]; then
  if [ -d "$MEMORY_DIR" ]; then
    echo "⚠ $MEMORY_DIR exists (a benchmark run wrote to it). Backing it up to .bench-during."
    mv "$MEMORY_DIR" "${MEMORY_DIR}.bench-during"
  fi
  mv "$MEMORY_BAK" "$MEMORY_DIR"
  echo "✓ Memory dir restored: $MEMORY_DIR"
else
  echo "⚠ No memory backup to restore — skipping."
fi

echo ""
echo "=========================================="
echo "  TEARDOWN COMPLETE"
echo "=========================================="
echo ""
echo "All 4 model outputs are at: output/m_runs/"
echo ""
ls -la output/m_runs/ 2>/dev/null || echo "  (empty)"
echo ""
echo "Next: tell me 'verify <model>' for each one, or 'verify all' to run"
echo "      the grep + Dart toolchain checks across all 4."
