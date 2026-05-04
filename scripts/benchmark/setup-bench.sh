#!/usr/bin/env bash
# Cross-model benchmark setup: create isolated git worktrees + park memory dir.
# Run once before you start the 4 model runs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

BRANCH="$(git branch --show-current)"
HEAD_SHA="$(git rev-parse HEAD)"
MODELS=(haiku sonnet opus codex)
MEMORY_DIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-flutter-templates/memory"
MEMORY_BAK="${MEMORY_DIR}.bench-bak"

echo "Repo:     $REPO_ROOT"
echo "Branch:   $BRANCH"
echo "Models:   ${MODELS[*]}"
echo ""

# 1. Park the auto-memory dir so model runs can't leak state into each other.
if [ -d "$MEMORY_DIR" ] && [ ! -d "$MEMORY_BAK" ]; then
  mv "$MEMORY_DIR" "$MEMORY_BAK"
  echo "✓ Memory dir parked at: $MEMORY_BAK"
elif [ -d "$MEMORY_BAK" ]; then
  echo "⚠ Memory backup already exists ($MEMORY_BAK) — skipping. Run teardown first if this is stale."
else
  echo "⚠ No memory dir found — skipping. (This is fine.)"
fi

# 2. Create 4 worktrees alongside the main repo dir.
PARENT="$(dirname "$REPO_ROOT")"
for M in "${MODELS[@]}"; do
  WT="$PARENT/bench-$M"
  if [ -d "$WT" ]; then
    echo "⚠ Worktree already exists: $WT — skipping."
  else
    # --detach: check out the commit without binding to a branch. Lets 4 worktrees
    # coexist on the same underlying commit. Models don't commit anything, so this
    # is fine — they just need the files.
    git worktree add --detach "$WT" "$HEAD_SHA" >/dev/null
    mkdir -p "$WT/output/m_runs/$M"
    echo "✓ Worktree: $WT  (detached @ ${HEAD_SHA:0:7})"
  fi
done

echo ""
echo "=========================================="
echo "  SETUP COMPLETE — next steps"
echo "=========================================="
echo ""
echo "Run each model in its own worktree, sequentially. One terminal is fine."
echo ""
cat <<'STEPS'
Example (Haiku):
  cd ../bench-haiku
  START=$(date +%s) && claude --model claude-haiku-4-5-20251001
  # Inside Claude: paste the benchmark prompt from output/BENCHMARK_CHECKLIST.md
  # After /exit, it prints the duration. Record it.

Then Sonnet:
  cd ../bench-sonnet
  START=$(date +%s) && claude --model claude-sonnet-4-6

Then Opus:
  cd ../bench-opus
  START=$(date +%s) && claude --model claude-opus-4-7

Then Codex:
  cd ../bench-codex
  codex

For each AI's prompt, paste:

-----8<------
I'm benchmarking Flutter template generation for a team proposal. Follow
the spec in specs/generation-prompt.md exactly — use the parameters already
in the Parameters section and follow the instructions between START and END
markers. Create the project under output/m_runs/<model>/ (I'll tell you
which model you are — haiku | sonnet | opus | codex).

When you're done:
  (a) Tell me how many files you created.
  (b) Run the grep self-check from the prompt and tell me the leftover count.
  (c) List every clarification question you considered asking, every retry
      you did, and every error you hit.

Do not skip any of (a), (b), (c). They are the benchmark data points.
-----8<------

Replace <model> with the actual model name before you paste, so the AI knows
where to write output.
STEPS
echo ""
echo "When all 4 runs are done, come back and run:"
echo "  bash output/teardown-bench.sh"
