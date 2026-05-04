#!/usr/bin/env bash
# Multi-model edge-case benchmark setup: 8 worktrees (haiku × 4 cases, sonnet × 4 cases).
# Run once before the 8 manual Claude sessions.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

HEAD_SHA="$(git rev-parse HEAD)"
MEMORY_DIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-flutter-templates/memory"
MEMORY_BAK="${MEMORY_DIR}.bench-bak"
PARENT="$(dirname "$REPO_ROOT")"

# Same 4 edge cases as Round 2 (Opus) — reused for direct comparability.
# Format: case_name|project_name|package_name|app_name|app_version|build_number|json_field_rename|add_permission_handler
CASES=(
  "perms|test_perms|co.nimblehq.testperms|Test Perms|0.1.0|1|snake|true"
  "apostrophe|bobs_app|co.nimblehq.bobsapp|Bob's Dashboard|0.1.0|1|snake|false"
  "longname|enterprise_dashboard_app|co.nimblehq.enterprise.dashboard|Enterprise Dashboard|2.5.1|42|snake|false"
  "norename|no_rename_app|co.nimblehq.norename|No Rename App|0.1.0|1|none|false"
)

MODELS=(haiku sonnet)

echo "Repo:   $REPO_ROOT"
echo "HEAD:   $HEAD_SHA"
echo "Models: ${MODELS[*]}"
echo "Cases:  perms apostrophe longname norename"
echo ""

# Park memory (only if not already)
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

for MODEL in "${MODELS[@]}"; do
  for CASE_LINE in "${CASES[@]}"; do
    IFS='|' read -r NAME PROJ PKG APP VER BN RENAME PERMS <<< "$CASE_LINE"
    WT="$PARENT/bench-models-${MODEL}-${NAME}"

    if [ -d "$WT" ]; then
      echo "⚠ Worktree exists: $WT — skipping."
    else
      git worktree add --detach "$WT" "$HEAD_SHA" >/dev/null
      _edit_params "$WT" "$PROJ" "$PKG" "$APP" "$VER" "$BN" "$RENAME" "$PERMS"
      mkdir -p "$WT/output/m_runs_models/${MODEL}/${NAME}"
      echo "✓ ${MODEL}-${NAME} → $WT"
    fi
  done
done

echo ""
echo "=========================================="
echo "  SETUP COMPLETE — run 8 sessions"
echo "=========================================="
cat <<'STEPS'

Run each session manually. Sequential is recommended (avoids file-system contention).
Memory dir is parked — every session starts fresh.

In each session, paste the standard benchmark prompt with the matching output path:
  output path = output/m_runs_models/<model>/<case>/

────────────────────────────────────────────
HAIKU (claude-haiku-4-5-20251001)
────────────────────────────────────────────
  cd ../bench-models-haiku-perms
  START=$(date +%s); claude --model claude-haiku-4-5-20251001; echo "Duration: $(($(date +%s) - START))s"

  cd ../bench-models-haiku-apostrophe
  START=$(date +%s); claude --model claude-haiku-4-5-20251001; echo "Duration: $(($(date +%s) - START))s"

  cd ../bench-models-haiku-longname
  START=$(date +%s); claude --model claude-haiku-4-5-20251001; echo "Duration: $(($(date +%s) - START))s"

  cd ../bench-models-haiku-norename
  START=$(date +%s); claude --model claude-haiku-4-5-20251001; echo "Duration: $(($(date +%s) - START))s"

────────────────────────────────────────────
SONNET (claude-sonnet-4-6)
────────────────────────────────────────────
  cd ../bench-models-sonnet-perms
  START=$(date +%s); claude --model claude-sonnet-4-6; echo "Duration: $(($(date +%s) - START))s"

  cd ../bench-models-sonnet-apostrophe
  START=$(date +%s); claude --model claude-sonnet-4-6; echo "Duration: $(($(date +%s) - START))s"

  cd ../bench-models-sonnet-longname
  START=$(date +%s); claude --model claude-sonnet-4-6; echo "Duration: $(($(date +%s) - START))s"

  cd ../bench-models-sonnet-norename
  START=$(date +%s); claude --model claude-sonnet-4-6; echo "Duration: $(($(date +%s) - START))s"

When all 8 runs are done:
  cd /Users/khanh/Desktop/Code/flutter-templates
  bash output/teardown-models-bench.sh
  bash output/verify-models.sh
STEPS
