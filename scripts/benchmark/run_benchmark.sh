#!/usr/bin/env bash
# Benchmark: does validation_test.dart catch anything flutter build apk doesn't?
# For each broken_N: record pass/fail at each gate.
set +e  # continue past failures

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"
SAMPLE_DIR="$REPO_ROOT/sample"
VALIDATION_TEST="$REPO_ROOT/specs/validation/validation_test.dart"
RESULTS="$REPO_ROOT/output/benchmark_results.txt"

echo "benchmark,gate,outcome,log" > "$RESULTS"

_run() {
  local name="$1" gate="$2" cmd="$3" proj="$4"
  local log="/tmp/bench_${name}_${gate}.log"
  echo "--- $name : $gate ---"
  (cd "$proj" && eval "$cmd") > "$log" 2>&1
  local rc=$?
  local outcome=$([ $rc -eq 0 ] && echo "PASS" || echo "FAIL")
  echo "$name,$gate,$outcome,$log" >> "$RESULTS"
  echo "  → $outcome (log: $log)"
}

for n in 1_fastlane 2_display 3_namespace 4_pubspec 5_readme; do
  proj="$REPO_ROOT/output/broken_$n"
  echo ""
  echo "=========================="
  echo "  broken_$n"
  echo "=========================="

  _run "$n" "pub_get"       "flutter pub get"                                           "$proj"
  _run "$n" "build_runner"  "flutter pub run build_runner build --delete-conflicting-outputs" "$proj"
  _run "$n" "analyze"       "flutter analyze ."                                         "$proj"
  _run "$n" "test"          "flutter test"                                              "$proj"
  _run "$n" "dart_format"   "dart format --set-exit-if-changed ."                       "$proj"

  # Path A extra: validation_test.dart (copy in, run, remove)
  cp "$VALIDATION_TEST" "$proj/test/" 2>/dev/null
  _run "$n" "validation_test" "SAMPLE_DIR='$SAMPLE_DIR' flutter test test/validation_test.dart" "$proj"
  rm -f "$proj/test/validation_test.dart"

  # Path B extra: flutter build apk (slow, the real native gate)
  _run "$n" "build_apk"     "flutter build apk --debug"                                 "$proj"
done

echo ""
echo "============================"
echo "  RESULTS"
echo "============================"
column -t -s, "$RESULTS"
