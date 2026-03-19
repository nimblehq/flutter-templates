#!/usr/bin/env bash
set -euo pipefail
PROJECT_DIR="$(cd "${1:?Usage: validate.sh <project_dir>}" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAMPLE_DIR="$(cd "$SCRIPT_DIR/../../sample" && pwd)"

cd "$PROJECT_DIR"

echo "=== Build ==="
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

echo "=== Format ==="
dart format --set-exit-if-changed .

echo "=== Analyze ==="
flutter analyze .

echo "=== Validation + Tests ==="
cp "$SCRIPT_DIR/validation_test.dart" test/
SAMPLE_DIR="$SAMPLE_DIR" flutter test test/validation_test.dart
rm -f test/validation_test.dart
flutter test --coverage

echo "=== ALL PASSED ==="
