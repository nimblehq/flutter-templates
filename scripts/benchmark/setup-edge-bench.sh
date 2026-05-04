#!/usr/bin/env bash
# Edge-case benchmark setup: 4 worktrees, each with different params in specs/generation-prompt.md.
# Run once before the 4 Opus runs.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

HEAD_SHA="$(git rev-parse HEAD)"
MEMORY_DIR="$HOME/.claude/projects/-Users-khanh-Desktop-Code-flutter-templates/memory"
MEMORY_BAK="${MEMORY_DIR}.bench-bak"
PARENT="$(dirname "$REPO_ROOT")"

# Case definitions: name|project_name|package_name|app_name|app_version|build_number|json_field_rename|add_permission_handler
CASES=(
  "perms|test_perms|co.nimblehq.testperms|Test Perms|0.1.0|1|snake|true"
  "apostrophe|bobs_app|co.nimblehq.bobsapp|Bob's Dashboard|0.1.0|1|snake|false"
  "longname|enterprise_dashboard_app|co.nimblehq.enterprise.dashboard|Enterprise Dashboard|2.5.1|42|snake|false"
  "norename|no_rename_app|co.nimblehq.norename|No Rename App|0.1.0|1|none|false"
)

echo "Repo:   $REPO_ROOT"
echo "HEAD:   $HEAD_SHA"
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

  # Replace the Parameters block between ``` fences after "## Parameters"
  # Use python for cross-platform safety with special chars in app_name
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
# Match the ```\n<params>\n``` block that follows "## Parameters"
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
  WT="$PARENT/bench-edge-$NAME"

  if [ -d "$WT" ]; then
    echo "⚠ Worktree exists: $WT — skipping."
  else
    git worktree add --detach "$WT" "$HEAD_SHA" >/dev/null
    _edit_params "$WT" "$PROJ" "$PKG" "$APP" "$VER" "$BN" "$RENAME" "$PERMS"
    mkdir -p "$WT/output/m_runs_edge/$NAME"
    echo "✓ $NAME → $WT  ($PROJ | $PKG | '$APP' | perms=$PERMS | rename=$RENAME)"
  fi
done

echo ""
echo "=========================================="
echo "  SETUP COMPLETE — run Opus 4x"
echo "=========================================="
cat <<'STEPS'

Run each case in its worktree. All use Opus 4.7:

  # Case 1 — permission_handler=true (untested conditional)
  cd ../bench-edge-perms
  START=$(date +%s); claude --model claude-opus-4-7; echo "Duration: $(($(date +%s) - START))s"
  # Inside Claude, paste the standard benchmark prompt with:
  #   output path = output/m_runs_edge/perms/

  # Case 2 — app_name with apostrophe (string escaping)
  cd ../bench-edge-apostrophe
  START=$(date +%s); claude --model claude-opus-4-7; echo "Duration: $(($(date +%s) - START))s"
  # output path = output/m_runs_edge/apostrophe/

  # Case 3 — long project_name + nested package (identifier propagation)
  cd ../bench-edge-longname
  START=$(date +%s); claude --model claude-opus-4-7; echo "Duration: $(($(date +%s) - START))s"
  # output path = output/m_runs_edge/longname/

  # Case 4 — json_field_rename=none (alternate codegen behavior)
  cd ../bench-edge-norename
  START=$(date +%s); claude --model claude-opus-4-7; echo "Duration: $(($(date +%s) - START))s"
  # output path = output/m_runs_edge/norename/

When all 4 runs are done:
  cd /Users/khanh/Desktop/Code/flutter-templates
  bash output/teardown-edge-bench.sh
STEPS
