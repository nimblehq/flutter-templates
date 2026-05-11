#!/usr/bin/env bash
# Verify all 8 multi-model outputs (haiku × 4 + sonnet × 4) with the full build pipeline.
set +e  # continue past failures

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RESULTS="$REPO_ROOT/output/verify-models-results.txt"
echo "model,case,stage,outcome,duration_s,notes" > "$RESULTS"

_run() {
  local model="$1" case="$2" stage="$3" cmd="$4" dir="$5"
  local log="/tmp/verify_models_${model}_${case}_${stage}.log"
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
  echo "${model},${case},${stage},${outcome},${dur}s,${notes}" >> "$RESULTS"
  printf "  [%s] %4s %-14s %s\n" "$outcome" "${dur}s" "$stage" "$notes"
}

MODELS=(haiku sonnet)
CASES=(perms apostrophe longname norename)

for MODEL in "${MODELS[@]}"; do
  for CASE in "${CASES[@]}"; do
    echo ""
    echo "=============================="
    echo "  ${MODEL} / ${CASE}"
    echo "=============================="

    BASE="$REPO_ROOT/output/m_runs_models/${MODEL}/${CASE}"

    PROJ=$(find "$BASE" -name "pubspec.yaml" -not -path "*/ios/Pods/*" -not -path "*/build/*" 2>/dev/null | head -1)

    if [ -z "$PROJ" ]; then
      echo "  SKIP: no pubspec.yaml found under $BASE"
      echo "${MODEL},${CASE},all,SKIP,0s,no-pubspec" >> "$RESULTS"
      continue
    fi

    PROJ=$(dirname "$PROJ")
    echo "  project: $PROJ"

    _run "$MODEL" "$CASE" "grep_leftover" \
      "grep -rn 'co\\.nimblehq\\.flutter\\.template\\|package:sample/\\|nimblehq/sample\\|Flutter Templates\\|name: sample' . \
        --include='*.dart' --include='*.yaml' --include='*.yml' --include='*.xml' \
        --include='*.gradle' --include='*.rb' --include='*.pbxproj' --include='*.xcscheme' \
        --include='*.plist' --include='*.properties' --include='*.pro' --include='*.md' \
        --include='*.kt' --include='*.swift' --include='*.json' --include='*.arb'" \
      "$PROJ"

    _run "$MODEL" "$CASE" "pub_get"      "flutter pub get"                                                "$PROJ"
    _run "$MODEL" "$CASE" "build_runner" "dart run build_runner build --delete-conflicting-outputs"       "$PROJ"
    _run "$MODEL" "$CASE" "analyze"      "flutter analyze ."                                              "$PROJ"
    _run "$MODEL" "$CASE" "test"         "flutter test"                                                   "$PROJ"
    _run "$MODEL" "$CASE" "build_apk"    "flutter build apk --debug --flavor staging -t lib/main.dart"    "$PROJ"
    _run "$MODEL" "$CASE" "build_ios"    "flutter build ios --debug --no-codesign --flavor staging -t lib/main.dart" "$PROJ"
  done
done

echo ""
echo "=============================="
echo "  SUMMARY"
echo "=============================="
column -t -s, "$RESULTS"
echo ""
echo "Full logs: /tmp/verify_models_<model>_<case>_<stage>.log"
