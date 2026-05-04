#!/usr/bin/env bash
# Edge-case benchmark teardown: collect outputs, remove worktrees, restore memory.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

CASES=(perms apostrophe longname norename)
PARENT="$(dirname "$REPO_ROOT")"
MEMORY_DIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-flutter-templates/memory"
MEMORY_BAK="${MEMORY_DIR}.bench-bak"

mkdir -p output/m_runs_edge
echo "Collecting outputs into $REPO_ROOT/output/m_runs_edge/"
echo ""

for CASE in "${CASES[@]}"; do
  WT="$PARENT/bench-edge-$CASE"
  SRC="$WT/output/m_runs_edge/$CASE"
  DST="$REPO_ROOT/output/m_runs_edge/$CASE"

  if [ -d "$SRC" ] && [ "$(ls -A "$SRC" 2>/dev/null)" ]; then
    rm -rf "$DST"
    cp -R "$SRC" "$DST"
    FILES=$(find "$DST" -type f | wc -l | tr -d ' ')
    echo "✓ $CASE → $DST ($FILES files)"
  else
    echo "⚠ $CASE produced no output at $SRC — skipping."
  fi
done

echo ""

for CASE in "${CASES[@]}"; do
  WT="$PARENT/bench-edge-$CASE"
  if [ -d "$WT" ]; then
    git worktree remove --force "$WT" 2>/dev/null && echo "✓ Removed worktree: $WT" || \
      (rm -rf "$WT" && echo "✓ Force-removed dir: $WT")
  fi
done

git worktree prune 2>/dev/null || true

echo ""

if [ -d "$MEMORY_BAK" ]; then
  if [ -d "$MEMORY_DIR" ]; then
    mv "$MEMORY_DIR" "${MEMORY_DIR}.bench-during-edge"
  fi
  mv "$MEMORY_BAK" "$MEMORY_DIR"
  echo "✓ Memory dir restored"
fi

echo ""
echo "=========================================="
echo "  TEARDOWN COMPLETE"
echo "=========================================="
ls -la output/m_runs_edge/ 2>/dev/null
echo ""
echo "Next: tell me 'verify edge' to run the build pipeline on all 4 cases."
