# Generation Prompt

## How to Use

1. Edit the 7 values in the `Parameters` section below
2. Copy from **---START PROMPT---** to **---END PROMPT---** and paste into Claude Code

---START PROMPT---

## Task

Generate a Flutter project based on `sample/`. Read each source file in `sample/`, apply the substitutions defined below, and write the result to a new project directory. Do not ask questions. Start generating files immediately.

## Parameters

```
project_name           = flutter_template                  
package_name           = co.nimblehq.flutter.template    
app_name               = Flutter Templates               
app_version            = 0.1.0                           
build_number           = 1                               
json_field_rename      = snake                           
add_permission_handler = false                           
```

**Constraint:** `package_name` must be a valid Apple bundle identifier — only alphanumeric characters (`A-Z`, `a-z`, `0-9`), hyphens (`-`), and periods (`.`). No underscores. If the value above contains invalid characters, stop and report the error — do not silently modify it.

## Method

For every file in `sample/`:
1. Read the file
2. Replace all hardcoded values with the corresponding parameter values
3. Write the result to `<project_name>/` at the same relative path
4. For binary files (`.png`, `.otf`, `.keystore`): copy without modification

The processing script below handles skip paths, binary detection, and substitutions automatically.

### How to process files

Initialize variables from the Parameters section, then process every file.

**Step 1 — Set variables** (run once before processing):

```bash
PROJECT_NAME="<project_name>"
PACKAGE_NAME="<package_name>"
APP_NAME="<app_name>"
APP_VERSION="<app_version>"
BUILD_NUMBER="<build_number>"
JSON_FIELD_RENAME="<json_field_rename>"
PROJECT_NAME_HYPHEN="${PROJECT_NAME//_/-}"
PACKAGE_PATH="${PACKAGE_NAME//\.//}"
```

Use the actual values from the Parameters section. `PROJECT_NAME_HYPHEN` converts underscores to hyphens. `PACKAGE_PATH` converts dots to forward slashes.

**Step 2 — Copy and transform** (run from the repo root):

```bash
cd sample
find . -type f \
  ! -path './build/*' ! -path './.dart_tool/*' ! -path './ios/Pods/*' \
  ! -path './.packages/*' ! -path './coverage/*' \
  ! -name '.flutter-plugins' ! -name '.flutter-plugins-dependencies' \
  ! -name 'Generated.xcconfig' ! -name 'flutter_export_environment.sh' \
  ! -name 'local.properties' ! -name '.generation_params' \
  | while read -r SRC; do
  TARGET_FILE="../${PROJECT_NAME}/${SRC}"
  mkdir -p "$(dirname "$TARGET_FILE")"
  cp -p "$SRC" "$TARGET_FILE"
  case "$SRC" in *.png|*.otf|*.keystore) continue ;; esac
  sed -i '' \
    -e 's/co\.nimblehq\.flutter\.template\.staging/'"$PACKAGE_NAME"'.staging/g' \
    -e 's/co\.nimblehq\.flutter\.template/'"$PACKAGE_NAME"'/g' \
    -e "s|co/nimblehq/flutter/template|$PACKAGE_PATH|g" \
    -e 's/Flutter Templates Staging/'"$APP_NAME"' Staging/g' \
    -e 's/Flutter Templates/'"$APP_NAME"'/g' \
    -e "s|package:sample/|package:$PROJECT_NAME/|g" \
    -e 's/name: sample/name: '"$PROJECT_NAME"'/g' \
    -e "s|<string>sample</string>|<string>$PROJECT_NAME</string>|g" \
    -e "s|nimblehq/sample|nimblehq/$PROJECT_NAME_HYPHEN|g" \
    -e 's/version: 1\.14\.0+1/version: '"$APP_VERSION"'+'"$BUILD_NUMBER"'/g' \
    -e 's/field_rename: "snake"/field_rename: "'"$JSON_FIELD_RENAME"'"/g' \
    "$TARGET_FILE"
done
cd ..
```

Key rules:
- **Staging before base:** The `.staging` pattern must come before the base pattern (already ordered above)
- **Delimiter `|`:** Use `|` instead of `/` for patterns containing slashes
- **Escaped dots:** All literal dots in find patterns are escaped (`\.`)
- **No bash substitution on file contents** — only use `${VAR//find/replace}` for computing variable values, never for transforming file text

### Substitution reference (the sed command above is the implementation; this table is documentation)

| Find (in `sample/`) | Replace with |
|---|---|
| `co.nimblehq.flutter.template.staging` | `<package_name>.staging` |
| `co.nimblehq.flutter.template` | `<package_name>` |
| `co/nimblehq/flutter/template` | `<package_name>` with `.` → `/` |
| `Flutter Templates Staging` | `<app_name> Staging` |
| `Flutter Templates` | `<app_name>` |
| `package:sample/` | `package:<project_name>/` |
| `name: sample` | `name: <project_name>` |
| `<string>sample</string>` | `<string><project_name></string>` |
| `nimblehq/sample` | `nimblehq/<project_name>` with `_` → `-` |
| `version: 1.14.0+1` | `version: <app_version>+<build_number>` |
| `field_rename: "snake"` | `field_rename: "<json_field_rename>"` |

### Android Kotlin directory

After the loop, move the Kotlin file to the correct package directory:

```bash
KOTLIN_SRC="${PROJECT_NAME}/android/app/src/main/kotlin/co/nimblehq/flutter/template"
KOTLIN_DST="${PROJECT_NAME}/android/app/src/main/kotlin/${PACKAGE_PATH}"
mkdir -p "$KOTLIN_DST"
mv "$KOTLIN_SRC/"* "$KOTLIN_DST/"
rm -rf "${PROJECT_NAME}/android/app/src/main/kotlin/co"
```

The sed already replaced package references inside `MainActivity.kt`. This step fixes only the directory path.

### Conditional: `add_permission_handler`

When `false`: remove the `permission_handler` dependency line from `pubspec.yaml`, and do NOT create `lib/utils/wrappers/permission_wrapper.dart`.

When `true`: keep both as-is from `sample/`.

## First file

Write `<project_name>/.generation_params` — the validation pipeline reads this file:

```
project_name=<value>
package_name=<value>
app_name=<value>
app_version=<value>
build_number=<value>
json_field_rename=<value>
add_permission_handler=<value>
```

Use the actual values from the Parameters section. Format: `key=value`, one per line, no spaces around `=`. Then proceed with all other files.

## Rules

- Do NOT generate `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.mocks.dart`, or `lib/gen/` — build_runner/flutter_gen creates these
- All Dart imports: `package:<project_name>/...` — never relative imports
- GitHub Actions: keep `${{ }}` syntax literally (not template syntax)
- Domain layer (`lib/domain/`) must not import from `lib/data/` or `lib/app/`
- Data layer (`lib/data/`) must not import from `lib/app/`
- Only substitute existing content — never add new lines, keys, or blocks that do not exist in `sample/`
- Do not leave debugging artifacts (log files, temp files) in the generated project
- Process every file in `sample/` not in the skip list — if a file causes a sed error, fix and retry rather than skipping it

## Validation

After generating all files, run these checks **in order**.

### Step 1: Check for leftover hardcoded values

```bash
grep -rn "co\.nimblehq\.flutter\.template\|package:sample/\|nimblehq/sample\|Flutter Templates" <project_name>/ \
  --include='*.dart' --include='*.yaml' --include='*.yml' --include='*.xml' \
  --include='*.gradle' --include='*.rb' --include='*.pbxproj' --include='*.xcscheme' \
  --include='*.plist' --include='*.properties' --include='*.pro' --include='*.md' \
  --include='*.kt' --include='*.swift' --include='*.json' --include='*.arb'
```

If this produces ANY output, fix the missed substitutions before continuing.

### Step 2: Check for missing files

```bash
diff <(cd sample && find . -type f \
  ! -path './build/*' ! -path './.dart_tool/*' ! -path './ios/Pods/*' \
  ! -path './.packages/*' ! -path './coverage/*' \
  ! -name '*.g.dart' ! -name '*.freezed.dart' ! -name '*.config.dart' ! -name '*.mocks.dart' \
  ! -path './lib/gen/*' \
  ! -name '.flutter-plugins' ! -name '.flutter-plugins-dependencies' \
  ! -name 'Generated.xcconfig' ! -name 'flutter_export_environment.sh' \
  ! -name 'local.properties' ! -name '.generation_params' \
  | sort) \
<(cd <project_name> && find . -type f ! -name '.generation_params' | sort)
```

Files only in the left column are missing — generate them. Files only in the right column (`.generation_params`) are expected.

### Step 3: Run the validation pipeline

```bash
bash specs/validation/validate.sh <project_name>
```

If any check fails, fix the issues and re-run from Step 1.

---END PROMPT---
