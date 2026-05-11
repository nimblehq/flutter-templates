#!/usr/bin/env bash
# Opus token-tracked rerun: 5 worktrees (1 baseline + 4 edge cases).
# Token usage is extracted post-run from ~/.claude/projects/<encoded-cwd>/*.jsonl
# — see extract-tokens.py and verify-opus-tokens.sh.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

HEAD_SHA="$(git rev-parse HEAD)"
MEMORY_DIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-flutter-templates/memory"
MEMORY_BAK="${MEMORY_DIR}.bench-bak"
PARENT="$(dirname "$REPO_ROOT")"
MODEL="opus"

# 1 baseline + 4 edge cases. Same edge cases as Round 3 for direct comparability.
# Format: case_name|project_name|package_name|app_name|app_version|build_number|json_field_rename|add_permission_handler
CASES=(
  "baseline|sample_app|co.nimblehq.sampleapp|Sample App|0.1.0|1|snake|false"
  "perms|test_perms|co.nimblehq.testperms|Test Perms|0.1.0|1|snake|true"
  "apostrophe|bobs_app|co.nimblehq.bobsapp|Bob's Dashboard|0.1.0|1|snake|false"
  "longname|enterprise_dashboard_app|co.nimblehq.enterprise.dashboard|Enterprise Dashboard|2.5.1|42|snake|false"
  "norename|no_rename_app|co.nimblehq.norename|No Rename App|0.1.0|1|none|false"
)

echo "Repo:   $REPO_ROOT"
echo "HEAD:   $HEAD_SHA"
echo "Model:  Claude Opus 4.7 (claude-opus-4-7)"
echo "Cases:  baseline perms apostrophe longname norename"
echo ""

# Park memory so every session starts fresh.
if [ -d "$MEMORY_DIR" ] && [ ! -d "$MEMORY_BAK" ]; then
  mv "$MEMORY_DIR" "$MEMORY_BAK"
  echo "✓ Memory parked at: $MEMORY_BAK"
elif [ -d "$MEMORY_BAK" ]; then
  echo "⚠ Memory backup already exists — skipping."
else
  echo "⚠ No memory dir found — skipping."
fi
echo ""

_edit_params() {
  local wt="$1" proj="$2" pkg="$3" app="$4" ver="$5" bn="$6" rename="$7" perms="$8"
  local params_file="$wt/specs/generation-prompt.md"

  python3 - "$params_file" "$proj" "$pkg" "$app" "$ver" "$bn" "$rename" "$perms" <<'PY'
import sys, re, pathlib
path, proj, pkg, app, ver, bn, rename, perms = sys.argv[1:]
text = pathlib.Path(path).read_text()
block = (
    "project_name           = " + proj + "\n"
    "package_name           = " + pkg + "\n"
    "app_name               = " + app + "\n"
    "app_version            = " + ver + "\n"
    "build_number           = " + bn + "\n"
    "json_field_rename      = " + rename + "\n"
    "add_permission_handler = " + perms
)
pat = re.compile(r"(## Parameters\s*\n+```\s*\n)(.*?)(\n```)", re.DOTALL)
new = pat.sub(lambda m: m.group(1) + block + m.group(3), text)
if new == text:
    sys.stderr.write("ERROR: did not find Parameters block to replace in " + path + "\n")
    sys.exit(1)
pathlib.Path(path).write_text(new)
PY
}

for CASE_LINE in "${CASES[@]}"; do
  IFS='|' read -r NAME PROJ PKG APP VER BN RENAME PERMS <<< "$CASE_LINE"
  WT="$PARENT/bench-${MODEL}-${NAME}"

  if [ -d "$WT" ]; then
    echo "⚠ Worktree exists: $WT — skipping."
  else
    git worktree add --detach "$WT" "$HEAD_SHA" >/dev/null
    _edit_params "$WT" "$PROJ" "$PKG" "$APP" "$VER" "$BN" "$RENAME" "$PERMS"
    mkdir -p "$WT/output/m_runs_opus_tokens/${NAME}"
    echo "✓ ${MODEL}-${NAME} → $WT"
  fi
done

echo ""
echo "=========================================="
echo "  SETUP COMPLETE — run 5 sessions"
echo "=========================================="
cat <<'STEPS'

For each case:
  1. Clear the project's session log dir (so token extraction sees ONE jsonl).
  2. cd into the worktree.
  3. Run claude with --model claude-opus-4-7.
  4. Paste the canonical prompt from scripts/benchmark/benchmark-prompt.md.
     Output path: output/m_runs_opus_tokens/<case>/

────────────────────────────────────────────
OPUS 4.7 — sequential, ~5 sessions
────────────────────────────────────────────
  WT_BASE="$(dirname "$(pwd)")"  # parent dir of the repo

  for CASE in baseline perms apostrophe longname norename; do
    PROJDIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-bench-opus-${CASE}"
    rm -rf "$PROJDIR"
    cd "$WT_BASE/bench-opus-${CASE}"
    START=$(date +%s)
    claude --model claude-opus-4-7
    echo "Duration ${CASE}: $(($(date +%s) - START))s"
  done

When all 5 runs are done:
  cd /Users/khanh/Desktop/Code/flutter-templates
  bash scripts/benchmark/verify-opus-tokens.sh
  # produces output/verify-opus-tokens-results.txt with build outcomes + token usage + cost
STEPS
