#!/usr/bin/env bash
# Verify Opus token-tracked rerun: build pipeline + token extraction for all 5 cases.
# Produces output/verify-opus-tokens-results.txt (build outcomes) and
# output/verify-opus-tokens-cost.txt (per-case tokens + estimated $).
set +e  # continue past failures

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PARENT="$(dirname "$REPO_ROOT")"
RESULTS="$REPO_ROOT/output/verify-opus-tokens-results.txt"
COSTS="$REPO_ROOT/output/verify-opus-tokens-cost.txt"
EXTRACT="$REPO_ROOT/scripts/benchmark/extract-tokens.py"

mkdir -p "$REPO_ROOT/output"
echo "case,stage,outcome,duration_s,notes" > "$RESULTS"
echo "case,input,output,cache_create,cache_read,total,cost_usd" > "$COSTS"

_run() {
  local case="$1" stage="$2" cmd="$3" dir="$4"
  local log="/tmp/verify_opus_${case}_${stage}.log"
  local start=$(date +%s)
  (cd "$dir" && eval "$cmd") > "$log" 2>&1
  local rc=$?
  local dur=$(( $(date +%s) - start ))
  local outcome=$([ $rc -eq 0 ] && echo "PASS" || echo "FAIL")
  local notes=""
  case "$stage" in
    analyze)       notes="issues=$(grep -cE '^\s*(warning|error|info)' "$log" 2>/dev/null || echo 0)" ;;
    test)          notes=$(grep -oE "All tests passed!|Some tests failed|[0-9]+ tests? (passed|failed)" "$log" | head -1) ;;
    grep_leftover) notes="matches=$(wc -l < "$log" | tr -d ' ')" ;;
  esac
  echo "${case},${stage},${outcome},${dur}s,${notes}" >> "$RESULTS"
  printf "  [%s] %4s %-14s %s\n" "$outcome" "${dur}s" "$stage" "$notes"
}

CASES=(baseline perms apostrophe longname norename)

for CASE in "${CASES[@]}"; do
  echo ""
  echo "=============================="
  echo "  opus / ${CASE}"
  echo "=============================="

  BASE="$REPO_ROOT/output/m_runs_opus_tokens/${CASE}"
  PROJ=$(find "$BASE" -name "pubspec.yaml" -not -path "*/ios/Pods/*" -not -path "*/build/*" 2>/dev/null | head -1)

  if [ -z "$PROJ" ]; then
    echo "  SKIP: no pubspec.yaml found under $BASE"
    echo "${CASE},all,SKIP,0s,no-pubspec" >> "$RESULTS"
  else
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
  fi

  # Token extraction — runs regardless of build outcome and regardless of whether
  # the worktree dir still exists. The extractor only uses the path string for
  # encoding; the JSONLs live in ~/.claude/projects/ and survive teardown.
  WT="$PARENT/bench-opus-${CASE}"
  python3 "$EXTRACT" "$CASE" "$WT" >> "$COSTS"
done

echo ""
echo "=============================="
echo "  BUILD SUMMARY"
echo "=============================="
column -t -s, "$RESULTS"

echo ""
echo "=============================="
echo "  TOKEN + COST SUMMARY"
echo "=============================="
column -t -s, "$COSTS"

echo ""
echo "Pricing assumed: Opus 4.7 list per https://platform.claude.com/docs/en/about-claude/pricing"
echo "  (in=\$5, out=\$25, cache_w_5m=\$6.25, cache_w_1h=\$10, cache_r=\$0.50 per M)."
echo "Note: /cost may report ~10–15% lower because it applies the 5m cache_write rate"
echo "      regardless of actual ephemeral type. Both are valid list-price interpretations."
echo "Override via OPUS_IN / OPUS_OUT / OPUS_CW5 / OPUS_CW1H / OPUS_CR env vars."
echo "Full build logs: /tmp/verify_opus_<case>_<stage>.log"
