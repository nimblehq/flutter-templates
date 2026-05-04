#!/usr/bin/env bash
# Verify each model's output with identical commands. No interpretation, just pass/fail.
set +e  # never abort — we want results for every model

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
RESULTS="$REPO_ROOT/output/verify-results.txt"

echo "model,stage,outcome,duration_s,notes" > "$RESULTS"

_run() {
  local model="$1" stage="$2" cmd="$3" dir="$4"
  local log="/tmp/verify_${model}_${stage}.log"
  local start=$(date +%s)
  (cd "$dir" && eval "$cmd") > "$log" 2>&1
  local rc=$?
  local dur=$(( $(date +%s) - start ))
  local outcome=$([ $rc -eq 0 ] && echo "PASS" || echo "FAIL")
  # Extract useful signal from log
  local notes=""
  case "$stage" in
    analyze)
      notes=$(grep -cE "^\s*(warning|error|info)" "$log" 2>/dev/null || echo 0)
      notes="issues=$notes"
      ;;
    test)
      notes=$(grep -oE "All tests passed!|Some tests failed|[0-9]+ tests? (passed|failed)" "$log" | head -1)
      ;;
    grep_leftover)
      notes=$(wc -l < "$log" | tr -d ' ')
      notes="matches=$notes"
      ;;
  esac
  echo "$model,$stage,$outcome,${dur}s,$notes" >> "$RESULTS"
  printf "  [%s] %4s %-14s %s\n" "$outcome" "${dur}s" "$stage" "$notes"
}

for MODEL in haiku sonnet opus codex; do
  echo ""
  echo "=============================="
  echo "  $MODEL"
  echo "=============================="

  # Find the project dir (alex_wang) inside
  BASE="$REPO_ROOT/output/m_runs/$MODEL"
  PROJ=$(find "$BASE" -maxdepth 1 -mindepth 1 -type d | head -1)

  if [ -z "$PROJ" ]; then
    echo "  SKIP: no project dir found under $BASE"
    echo "$MODEL,all,SKIP,0s,no-project-dir" >> "$RESULTS"
    continue
  fi

  echo "  project: $PROJ"

  # 1. grep self-check (cheapest, catches silent substitution misses)
  _run "$MODEL" "grep_leftover" \
    "grep -rn 'co\\.nimblehq\\.flutter\\.template\\|package:sample/\\|nimblehq/sample\\|Flutter Templates\\|name: sample' . \
      --include='*.dart' --include='*.yaml' --include='*.yml' --include='*.xml' \
      --include='*.gradle' --include='*.rb' --include='*.pbxproj' --include='*.xcscheme' \
      --include='*.plist' --include='*.properties' --include='*.pro' --include='*.md' \
      --include='*.kt' --include='*.swift' --include='*.json' --include='*.arb'" \
    "$PROJ"

  # 2. pub get
  _run "$MODEL" "pub_get" "flutter pub get" "$PROJ"

  # 3. build_runner (generates .g.dart / .freezed.dart / etc)
  _run "$MODEL" "build_runner" "dart run build_runner build --delete-conflicting-outputs" "$PROJ"

  # 4. format check (informational — sed/AI both can tweak line lengths)
  _run "$MODEL" "format_check" "dart format --set-exit-if-changed ." "$PROJ"

  # 5. static analysis
  _run "$MODEL" "analyze" "flutter analyze ." "$PROJ"

  # 6. unit + widget tests
  _run "$MODEL" "test" "flutter test" "$PROJ"

  # 7. Android build — the real "runnable" gate
  _run "$MODEL" "build_apk" "flutter build apk --debug --flavor staging -t lib/main.dart" "$PROJ"

  # 8. iOS build — same, no codesign
  _run "$MODEL" "build_ios" "flutter build ios --debug --no-codesign --flavor staging -t lib/main.dart" "$PROJ"
done

echo ""
echo "=============================="
echo "  SUMMARY"
echo "=============================="
column -t -s, "$RESULTS"
echo ""
echo "Full logs: /tmp/verify_<model>_<stage>.log"
