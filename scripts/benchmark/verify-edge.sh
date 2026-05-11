#!/usr/bin/env bash
# Verify the 4 edge-case Opus outputs with the full build pipeline.
set +e  # continue past failures

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RESULTS="$REPO_ROOT/output/verify-edge-results.txt"
echo "case,stage,outcome,duration_s,notes" > "$RESULTS"

_run() {
  local case="$1" stage="$2" cmd="$3" dir="$4"
  local log="/tmp/verify_edge_${case}_${stage}.log"
  local start=$(date +%s)
  (cd "$dir" && eval "$cmd") > "$log" 2>&1
  local rc=$?
  local dur=$(( $(date +%s) - start ))
  local outcome=$([ $rc -eq 0 ] && echo "PASS" || echo "FAIL")
  local notes=""
  case "$stage" in
    analyze) notes="issues=$(grep -cE '^\s*(warning|error|info)' "$log" 2>/dev/null || echo 0)" ;;
    test) notes=$(grep -oE "All tests passed!|Some tests failed|[0-9]+ tests? (passed|failed)" "$log" | head -1) ;;
    grep_leftover) notes="matches=$(wc -l < "$log" | tr -d ' ')" ;;
  esac
  echo "$case,$stage,$outcome,${dur}s,$notes" >> "$RESULTS"
  printf "  [%s] %4s %-14s %s\n" "$outcome" "${dur}s" "$stage" "$notes"
}

for CASE in perms apostrophe longname norename; do
  echo ""
  echo "=============================="
  echo "  $CASE"
  echo "=============================="

  BASE="$REPO_ROOT/output/m_runs_edge/$CASE"

  # Find the project root by locating pubspec.yaml — works for both nested and flat layouts
  PROJ=$(find "$BASE" -name "pubspec.yaml" -not -path "*/ios/Pods/*" -not -path "*/build/*" 2>/dev/null | head -1)

  if [ -z "$PROJ" ]; then
    echo "  SKIP: no pubspec.yaml found under $BASE"
    echo "$CASE,all,SKIP,0s,no-pubspec" >> "$RESULTS"
    continue
  fi

  PROJ=$(dirname "$PROJ")
  echo "  project: $PROJ"

  _run "$CASE" "grep_leftover" \
    "grep -rn 'co\\.nimblehq\\.flutter\\.template\\|package:sample/\\|nimblehq/sample\\|Flutter Templates\\|name: sample' . \
      --include='*.dart' --include='*.yaml' --include='*.yml' --include='*.xml' \
      --include='*.gradle' --include='*.rb' --include='*.pbxproj' --include='*.xcscheme' \
      --include='*.plist' --include='*.properties' --include='*.pro' --include='*.md' \
      --include='*.kt' --include='*.swift' --include='*.json' --include='*.arb'" \
    "$PROJ"

  _run "$CASE" "pub_get"      "flutter pub get"                                                "$PROJ"
  _run "$CASE" "build_runner" "dart run build_runner build --delete-conflicting-outputs"       "$PROJ"
  _run "$CASE" "analyze"      "flutter analyze ."                                              "$PROJ"
  _run "$CASE" "test"         "flutter test"                                                   "$PROJ"
  _run "$CASE" "build_apk"    "flutter build apk --debug --flavor staging -t lib/main.dart"    "$PROJ"
  _run "$CASE" "build_ios"    "flutter build ios --debug --no-codesign --flavor staging -t lib/main.dart" "$PROJ"
done

echo ""
echo "=============================="
echo "  SUMMARY"
echo "=============================="
column -t -s, "$RESULTS"
echo ""
echo "Full logs: /tmp/verify_edge_<case>_<stage>.log"
