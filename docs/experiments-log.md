# Experiments Log — Flutter Templates Mason→AI Migration

Running record of every benchmark and verification experiment we've run on this migration. Source of truth for the Notion proposal.

**Last updated:** 2026-05-04
**Branch:** feature/ai-generation-migration
**PR:** https://github.com/nimblehq/flutter-templates/pull/290

---

## Experiment Index

| # | Experiment | Date | Purpose | Outcome |
|---|---|---|---|---|
| 1 | Preliminary cross-model benchmark | 2026-04-21 | "Can multiple AIs produce a correct project?" | All 4 pass `analyze + test`. Methodological gap: no `flutter build`. |
| 2 | Breakage-detection benchmark | 2026-04-21 | "Does native tooling catch generation bugs?" | Native catches 4/5 classes; validation_test.dart redundant. |
| 3 | sample/ toolchain repair | 2026-04-22 | "Can we actually build sample/ end-to-end?" | Yes, after Gradle/AGP/plugin fixes. Committed as c908810. |
| 4 | Final cross-model benchmark with build gate | 2026-04-22 | "Do AI-generated projects actually build?" | Opus ✅, Sonnet ✅, **Haiku ships broken iOS Podfile**. |
| 5 | Opus edge-case stress test | 2026-04-22 | "Does Opus hold up on params we haven't touched?" | All 4 cases pass end-to-end. N=6 Opus runs, 0 failures. |
| 6 | Multi-model edge-case stress test (Haiku + Sonnet) | 2026-05-04 | "Do Haiku/Sonnet hold up under same edge cases as Opus?" | Sonnet 27/28 ✅. Haiku 22/28 — Podfile + apostrophe failures reproduce systematically. |

---

## Experiment 1 — Preliminary cross-model benchmark

**Date:** 2026-04-21
**Purpose:** First pass at "can AI reliably generate a Flutter project?" across multiple models.

### Methodology

- 4 models tested: Haiku 4.5, Sonnet 4.6, Opus 4.7, Codex (GPT-5)
- Isolation: git worktrees, memory parked
- Params: `alex_wang` / `co.alex.wang` / `add_permission_handler=false` + standard defaults
- Verification: `grep leftover + pub get + build_runner + analyze + test`
- **Gap:** `flutter build apk` and `flutter build ios` NOT run (local JDK/Gradle incompatibility blocked them)

### Results

| Model | Gen duration | Files | Leftover | Analyze | Test | Errors |
|---|---|---|---|---|---|---|
| Haiku 4.5 | 53s | 143 | 0 | ✅ | ✅ | 0 |
| Sonnet 4.6 | 1085s | 144 | 0 | ✅ | ✅ | 1 (self-resolved) |
| Opus 4.7 | 124s | 144 | 0 | ✅ | ✅ | 0 |
| Codex | 83s | 144 | 0 | ✅ | ✅ | 1 (Podfile regex, self-corrected via grep) |

### Conclusion (later proven incomplete)

"All 4 models produce equivalent correct output." Recommended Haiku as default for speed.

**Why this conclusion was wrong:** verification didn't include `flutter build`. The Podfile failure mode was invisible to `analyze + test`.

---

## Experiment 2 — Breakage-detection benchmark

**Date:** 2026-04-21
**Purpose:** Is native Flutter tooling enough to catch generation bugs, or do we need a custom 570-line validation suite?

### Methodology

Inject 5 deliberate bugs into a clean generated project. Run every verification tool. Record which tool catches which bug.

### Bugs injected

1. Fastlane `Constants.rb` reverted to `co.nimblehq.flutter.template` (iOS release-time string)
2. pbxproj `APP_DISPLAY_NAME` = "Flutter Templates" (cosmetic iOS)
3. Android `namespace` reverted (but Kotlin dir correctly moved)
4. `pubspec.yaml` `name: sample`, imports unchanged (broken Dart)
5. README still says `sample` instead of project name (doc drift)

### Truth table

| Bug | `grep` | `pub get` | `analyze` | `test` | `validation_test.dart` | `flutter build ios` (on sample/) |
|---|---|---|---|---|---|---|
| 1. Fastlane ID | ❌ miss | ❌ | ❌ | ❌ | ✅ catch | N/A (not compiled) |
| 2. pbxproj display | ❌ miss | ❌ | ❌ | ❌ | ✅ catch | ❌ (cosmetic) |
| 3. Android namespace | ❌ miss | ❌ | ❌ | ❌ | ✅ catch | ✅ (build would fail) |
| 4. pubspec name | ❌ miss | ❌ | ✅ catch | ✅ | ✅ catch | ✅ |
| 5. README doc drift | ❌ miss | ❌ | ❌ | ❌ | ❌ | ❌ |
| **bonus: Podfile sed bug (generate.sh)** | ❌ | ❌ | ❌ | ❌ | ❌ miss | ✅ catch |

### Conclusion

- Native tooling catches 4/5 deliberate bugs.
- The 5th (README drift) is caught by neither approach — document as a limitation.
- **Custom validation suite was built to catch failures that don't actually occur in AI output** (substitution misses). The failures that DO occur (structural Podfile bugs) weren't in its scope.
- Deleted the 570-line validation suite. It was protecting against the wrong failure mode.

---

## Experiment 3 — `sample/` toolchain repair

**Date:** 2026-04-22
**Purpose:** `flutter build apk/ios` on `sample/` itself fails on current JDK 21 + Gradle 7.5 + AGP 7.3.0 combo. Must unblock before "runnable" can be the benchmark gate.

### Root cause

`package_info_plus` v9.0.0 expects the declarative Flutter Gradle plugin interface. Sample/'s legacy `apply from: app_plugin_loader.gradle` pattern doesn't expose `flutter.compileSdkVersion` to library subprojects. Result: `compileSdkVersion is not specified` error from every unmigrated plugin.

### Fixes applied (commit c908810)

- `android/gradle/wrapper`: Gradle 7.5 → 7.6.3
- `android/settings.gradle`: legacy plugin loader → declarative `plugins { }` block
- `android/build.gradle`: removed obsolete `buildscript` block
- `android/app/build.gradle`: `apply plugin:` → `plugins { }` block at top; dropped kotlin-stdlib dep; `minSdkVersion 23 → 24` (flutter_secure_storage requirement)
- `pubspec.yaml`: `package_info_plus ^9.0.0 → ^8.3.0`

### Verification

- `flutter build apk --debug --flavor staging -t lib/main.dart` → ✅ produces APK
- `flutter build ios --debug --no-codesign --flavor staging -t lib/main.dart` → ✅ produces Runner.app
- APK installed on Pixel 7 emulator → launches, MainActivity runs

### Deferred (not blocking)

- AGP 8.x modernization (hit namespace issues with unmigrated plugins like flutter_config)
- compileSdk 34 → 36 (newer plugins want it; Flutter is tolerant)

---

## Experiment 4 — Final cross-model benchmark with build gate

**Date:** 2026-04-22
**Purpose:** Re-run the cross-model benchmark with `flutter build apk + flutter build ios` as the new verification gate. Make "runnable" the bar, not just "analyzable."

### Methodology

Same isolation as Experiment 1. Added build stages to verify-all.sh. Skipped Codex (CLI not installed). Added self-reported structural-ops checklist to the prompt:
- Kotlin directory move
- permission_handler removal (conditional)
- permission_wrapper.dart not created (conditional)
- Podfile GCC_PREPROCESSOR_DEFINITIONS block removed (conditional)

### Generation phase (self-reports)

| Model | Duration | Files | Leftover | Retries | Errors | Self-reported structural ops |
|---|---|---|---|---|---|---|
| Haiku 4.5 | **322s** | 144 | 0 | 1 | 2 | **All ✅ (self-report was WRONG)** |
| Sonnet 4.6 | 128s | 144 | 0 | 0 | 0 | all ✅ |
| Opus 4.7 | 174s | 144 | 0 | 2 | 1 | all ✅ |

### Verification phase (objective)

| Stage | Haiku | Sonnet | Opus |
|---|---|---|---|
| grep leftover | ✅ 0 | ✅ 0 | ✅ 0 |
| pub get | ✅ 6s | ✅ 2s | ✅ 2s |
| build_runner | ✅ 27s | ✅ 23s | ✅ 24s |
| analyze | ✅ 0 | ✅ 0 | ✅ 0 |
| test | ✅ pass | ✅ pass | ✅ pass |
| **build apk** | ✅ 41s | ✅ 24s | ✅ 26s |
| **build ios** | ❌ **FAIL** | ✅ 46s | ✅ 39s |

### The Haiku finding

Haiku's self-report claimed ✅ on "Removed full GCC_PREPROCESSOR_DEFINITIONS block from ios/Podfile." Actual Podfile content:

```ruby
# ... 11 orphan comment lines that were inside the deleted block ...
      # 'PERMISSION_CRITICAL_ALERTS=1'
      ]                                    ← ORPHAN closing bracket
    end
  end
end
```

`pod install` fails with `Invalid Podfile file: syntax error, unexpected ']'`. **Same bug shape as the bash `generate.sh` Podfile sed bug.** The AI's self-check (grep) didn't catch it because a bare `]` doesn't match any substitution pattern. Only `flutter build ios` caught it.

### Conclusions

1. **Preliminary benchmark (Experiment 1) got the recommendation wrong** — Haiku is NOT a safe default. Silent iOS failure.
2. **AI self-reports are not trustworthy** for structural operations. Native build is load-bearing.
3. **Updated recommendation: Opus 4.7 primary, Sonnet 4.6 secondary.** Haiku only with build-retry harness as protection.
4. **Variance is real and larger than initial variance caveat suggested.** Sonnet: 1085s round 1, 128s round 2. Same model, same prompt, 8x speed difference.

---

## Experiment 5 — Opus edge-case stress test

**Date:** 2026-04-22
**Purpose:** Before declaring "Opus-only, no harness needed," test Opus on param sets we haven't benchmarked. Failure = harness required. Pass = Opus-only is defensible.

### Methodology

4 edge-case param sets, each in its own git worktree with params edited into `specs/generation-prompt.md`. Opus 4.7 only. Same prompt structure as Experiment 4 with case-specific structural-ops checklists.

### Case 5.1 — `add_permission_handler=true` (untested conditional) ✅

Tests the opposite conditional path — KEEP permission_handler artifacts instead of remove.

**Params:**
```
project_name           = test_perms
package_name           = co.nimblehq.testperms
app_name               = Test Perms
app_version            = 0.1.0
build_number           = 1
json_field_rename      = snake
add_permission_handler = true        ← flipped
```

**Result:**
- duration: 100s
- Files: **145** (one more than `=false` runs — `permission_wrapper.dart` kept)
- Leftover: 0 ✓
- Retries: 1 (cd/pwd mechanics, not generation logic)
- Structural ops: all ✅
  - Kotlin dir moved correctly
  - KEPT `permission_handler: ^12.0.1` in pubspec
  - KEPT `lib/utils/wrappers/permission_wrapper.dart` intact (correctly noted its imports are `package:permission_handler/...`, not `package:sample/...`, so no substitution applies)
  - KEPT GCC_PREPROCESSOR_DEFINITIONS block intact in Podfile
- Verification (build apk/ios): pending — will run in teardown

**Finding:** Opus correctly distinguishes template-internal imports (need substitution) from third-party package imports (leave alone). A subtle semantic distinction.

### Case 5.2 — `app_name` with apostrophe (string escaping stress) ✅

Tests escaping across 7 file formats (Ruby, Dart, XML, markdown, pbxproj, plist).

**Params:**
```
project_name           = bobs_app
package_name           = co.nimblehq.bobsapp
app_name               = Bob's Dashboard     ← apostrophe
app_version            = 0.1.0
build_number           = 1
json_field_rename      = snake
add_permission_handler = false
```

**Result:**
- duration: 256s (4m 16s) — longer due to escaping audit
- Files: 144
- Leftover: 0 ✓
- Retries: **2** — grep cwd + **Dart parse-error prevention**
- Errors: 1 prevented — surfaced 3 Dart integration-test files with single-quoted string literals that would have broken parse on the apostrophe. Proactively flipped each to double-quoted.
- Structural ops: all ✅
- **Escaping audit across 7 formats, all correct:**
  - README.md: plain markdown, no escape
  - pbxproj: double-quotes, apostrophe legal
  - Constants.rb: pre-flipped quotes before substitution
  - Android strings.xml (main + staging): `\'` backslash-escape (aapt requirement)
  - 3 Dart integration-test files: switched single→double-quoted
  - Info.plist: placeholder, no literal app_name

**Finding:** This is the first run where Opus did preventive, cross-format escaping reasoning. Without this, at least 3 Dart files would have failed `flutter analyze`. The AI caught what a naive find-and-replace wouldn't.

### Case 5.3 — long project_name + nested package ✅

Tests identifier propagation across 18+ Dart import prefixes, 3-level nested Kotlin path, non-default version/build.

**Params:**
```
project_name           = enterprise_dashboard_app
package_name           = co.nimblehq.enterprise.dashboard
app_name               = Enterprise Dashboard
app_version            = 2.5.1
build_number           = 42
json_field_rename      = snake
add_permission_handler = false
```

**Result:**
- duration: 131s (~2m 11s)
- Files: 144
- Leftover: 0 ✓
- Retries: 0 on generation; 1 bash cwd adjustment
- Structural ops: all ✅
- Identifier propagation audit: 18 distinct `package:enterprise_dashboard_app/` prefixes, Kotlin package `co.nimblehq.enterprise.dashboard` (3-level nested), pubspec `name: enterprise_dashboard_app`. Zero partial substitutions or orphan `co.nimblehq.flutter.template` / `flutter/template` / `package:sample/` / `Flutter Templates` / `name: sample` / `nimblehq/sample`.
- Version audit: pubspec `version: 2.5.1+42`, zero orphan `1.14.0` strings.
- Verification (build apk/ios): pending.

**Findings:**
- Opus correctly distinguishes `project_name` (used in `name:` field, Dart imports, repo slug) from `package_name` (used in Android namespace, Kotlin package, iOS bundle ID). A naive model could conflate these.
- Footnote: Opus left `.generation_params` with the historical sample values (`app_version=0.1.0`, `build_number=1`) rather than updating. Defensible — that file isn't in the substitution table, and it's legacy metadata, not runtime config. But worth flagging: a validation suite that checked `.generation_params` vs actual would flag a mismatch.

### Case 5.4 — `json_field_rename=none` ✅

Tests alternate codegen config parameter.

**Params:**
```
project_name           = no_rename_app
package_name           = co.nimblehq.norename
app_name               = No Rename App
app_version            = 0.1.0
build_number           = 1
json_field_rename      = none        ← was always "snake"
add_permission_handler = false
```

**Result:**
- duration: 190s (~3m 10s)
- Files: 144
- Leftover: 0 ✓
- Retries: 1 (bash cwd drift — same failure mode as cases 2 and 3, minor tool-level not generation)
- Structural ops: all ✅
- json_field_rename audit: `build.yaml` line 7 `field_rename: "none"`, no other `field_rename:` entries in project, zero orphan `"snake"` values.
- Verification (build apk/ios): pending.

**Findings:**
- Opus did semantic analysis, not just text substitution. Correctly noted that shipped @JsonSerializable models (`UserResponse` with `email` and `username`) use single-word lowercase field names, so `snake` vs `none` produces **identical JSON for current shipped models** — but future multi-word fields (`firstName`) will serialize differently under `none` than under `snake`.
- This is a real downstream gotcha most generators would miss. Documents the subtle config→runtime implication for the next developer adding a multi-word field.

---

## Edge-case benchmark summary

**All 4 Opus runs on edge cases passed generation correctness checks** (grep leftover = 0, structural ops ✅, no hallucinated files).

| Case | Duration | Retries | Errors | Unique insight |
|---|---|---|---|---|
| 5.1 perms=true | 100s | 1 (tool) | 0 gen | Distinguished template-internal vs third-party package imports |
| 5.2 apostrophe | 256s | 2 (1 gen — Dart parse) | 0 prevented | Pre-flipped string quote styles across 7 file formats |
| 5.3 longname | 131s | 0 gen | 0 | Clean propagation across 18 Dart import prefixes + 3-level Kotlin path |
| 5.4 norename | 190s | 1 (tool) | 0 gen | Semantic analysis of codegen config effect on shipped vs future models |

**Verification phase result: all 4 cases pass every stage including `flutter build apk` and `flutter build ios`.**

| Stage | perms=true | apostrophe | longname | norename |
|---|:-:|:-:|:-:|:-:|
| grep leftovers | ✅ 0 | ✅ 0 | ✅ 0 | ✅ 0 |
| `flutter pub get` | ✅ 3s | ✅ 4s | ✅ 2s | ✅ 2s |
| `dart run build_runner build` | ✅ 22s | ✅ 24s | ✅ 23s | ✅ 25s |
| `flutter analyze` | ✅ 0 | ✅ 0 | ✅ 0 | ✅ 0 |
| `flutter test` | ✅ pass | ✅ pass | ✅ pass | ✅ pass |
| **`flutter build apk`** | ✅ 35s | ✅ 27s | ✅ 30s | ✅ 28s |
| **`flutter build ios`** | ✅ 56s | ✅ 35s | ✅ 38s | ✅ 47s |

**Opus passed 4/4 edge cases end-to-end, on both Android and iOS.** Combined with the previous round-2 benchmark, Opus has now been validated across 6 independent runs with 0 failures.

A consistent minor Opus quirk across cases 2/3/4: bash working-directory drift after `cd` — not a generation bug, tool-use issue that adds ~1 retry per run. Does not affect output correctness.

---

## Aggregate Opus validation across all experiments

| Test | Params variant | Gate | Result |
|---|---|---|---|
| Experiment 1 | default `alex_wang` | analyze + test | ✅ |
| Experiment 4 | default `alex_wang` | + build apk + build ios | ✅ |
| Experiment 5.1 | `permission_handler=true` | + build apk + build ios | ✅ |
| Experiment 5.2 | apostrophe in app_name | + build apk + build ios | ✅ |
| Experiment 5.3 | long name + nested package | + build apk + build ios | ✅ |
| Experiment 5.4 | `json_field_rename=none` | + build apk + build ios | ✅ |

**N=6 independent runs, 0 failures on the runnable gate.**

### Harness engineering decision

Based on this evidence: **harness engineering is NOT required for v1.**

The original concern was Haiku's silent iOS failure (Experiment 4). Opus does not exhibit this failure mode. Opus's self-reports are accurate, it proactively prevents downstream bugs (Dart parse errors from apostrophes), and it handles diverse param combinations correctly.

Harness remains a valid future investment IF:
- Adoption broadens beyond Nimble (external teams, different toolchains)
- A previously-untested param combination surfaces a real failure
- We switch default model away from Opus
- We want architectural invariant enforcement on ongoing code review (independent of generation)

Design preserved in the Notion proposal for future reference. Not blocking v1.

---

## Experiment 6 — Multi-model edge-case stress test (Haiku + Sonnet)

**Date:** 2026-05-04
**Purpose:** Apply the same 4 edge-case parameter sets used on Opus (Experiment 5) to Haiku 4.5 and Sonnet 4.6. Get a fair head-to-head matrix across all three Claude models.

### Methodology

- 8 manual sessions: 2 models × 4 cases (perms, apostrophe, longname, norename)
- Same git-worktree isolation + parked memory dir as previous rounds
- **Canonical prompt pinned to** `scripts/benchmark/benchmark-prompt.md` — no per-session phrasing drift
- Same edge-case param sets as Experiment 5, byte-identical via `scripts/benchmark/setup-models-bench.sh`
- Verification: full pipeline including `flutter build apk` + `flutter build ios`
- Codex skipped (different ecosystem, teammates use Claude)

### Generation phase (self-reports)

All 8 runs self-reported clean: "all 4 verification steps pass." Notable behaviors:
- **Haiku longname**: created output at `HAIKU/baseline/<project>/` instead of canonical path. Required manual `mv` before teardown. Indicates Haiku doesn't follow non-explicit path instructions reliably.
- **Sonnet apostrophe**: proactively flipped 3 Dart integration test files single → double quotes — the same fix Opus applied in Experiment 5.2. Closes the "latent risk" caveat from Experiment 4.
- **Sonnet apostrophe artifacts**: 1091 files in output dir vs ~280 for the others — Sonnet committed `build/`, `.dart_tool/`, iOS `Pods/` artifacts before stopping.

### Verification phase (objective)

| Model / Case | grep | pub_get | build_runner | analyze | test | build_apk | build_ios |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **haiku/perms** | ✅ | ✅ 2s | ✅ 17s | ✅ 0 | ✅ | ✅ 35s | ✅ 44s |
| **haiku/apostrophe** | ✅ | ✅ 2s | ❌ 25s | ❌ 34 issues | ✅ | ❌ 15s | ❌ 7s |
| **haiku/longname** | ✅ | ✅ 2s | ✅ 21s | ✅ 0 | ✅ | ✅ 27s | ❌ 8s |
| **haiku/norename** | ✅ | ✅ 3s | ✅ 20s | ✅ 0 | ✅ | ✅ 29s | ❌ 9s |
| **sonnet/perms** | ✅ | ✅ 3s | ✅ 19s | ✅ 0 | ✅ | ✅ 29s | ✅ 49s |
| **sonnet/apostrophe** | ✅ | ✅ 3s | ✅ 20s | ✅ 0 | ✅ | ❌ 14s | ✅ 36s |
| **sonnet/longname** | ✅ | ✅ 3s | ✅ 19s | ✅ 0 | ✅ | ✅ 24s | ✅ 38s |
| **sonnet/norename** | ✅ | ✅ 2s | ✅ 22s | ✅ 0 | ✅ | ✅ 21s | ✅ 35s |

### Failure mode 1 — Haiku iOS Podfile orphan `]` (systematic)

Reproduced from Experiment 4. When `add_permission_handler=false`, Haiku deletes the contents of the `GCC_PREPROCESSOR_DEFINITIONS` array but leaves the closing `]`:

```
Invalid `Podfile` file: syntax error, unexpected ']'
      ]
      ^
```

**N=2/2 reproduces** on cases that exercised this conditional (longname, norename). Apostrophe case never reached iOS stage because Dart codegen broke first. Perms case kept the block (`perms=true`) so the bug wasn't triggered.

This is now documented across **3 independent Haiku runs**: Experiment 4 baseline + Experiment 6 longname + Experiment 6 norename. **Not a fluke** — it's a systematic Haiku behavior on this conditional.

### Failure mode 2 — Haiku apostrophe (catastrophic)

Haiku didn't escape the apostrophe in `Bob's Dashboard` for Dart string literals. Cascading failure:
- `dart run build_runner` fails (codegen can't parse Dart)
- `flutter analyze` reports 34 issues
- `flutter test` passes coincidentally (tests don't depend on the broken codegen targets)
- `flutter build apk` fails
- `flutter build ios` fails

`flutter test` passing is misleading — that's why self-report was "all 4 tests passed."

### Failure mode 3 — Sonnet apostrophe Android XML (NEW finding)

Sonnet correctly fixed the Dart side (double-quoted strings) but missed the **Android resource** side. The app_name `Bob's Dashboard` gets injected into Gradle-generated `gradleResValues.xml` for `app_name`. Android XML requires `'` to be escaped as `\'` or `&apos;`.

```
gradleResValues.xml: string/app_name does not contain a valid string resource
"Invalid unicode escape sequence in string {str}"
Execution failed for task ':app:mergeStagingDebugResources'
```

**Self-verification missed it** because `flutter test` doesn't trigger Android resource compilation. Only `flutter build apk` exposes it. iOS build passed because pbxproj already uses double-quotes.

**Opus handled both Dart AND Android XML on the equivalent edge case in Experiment 5.2.** This is a meaningful Opus advantage that only surfaces on `'` in app names.

### Final scorecard across all 3 models

| Model | Cases full-pass | Stages pass | Failure modes |
|---|---|---|---|
| **Opus** | 4/4 | **28/28** | none observed in 6 runs |
| **Sonnet** | 3/4 | 27/28 | Android XML apostrophe escaping |
| **Haiku** | 1/4 | 22/28 | Dart apostrophe (catastrophic), iOS Podfile (systematic) |

### Conclusions

1. **Opus is uniquely reliable on edge cases.** N=6 runs, 0 failures across `perms=true`, apostrophe, long+nested name, alternate codegen.
2. **Sonnet is "Opus-level on standard params, latent gap on apostrophe."** If app_name has no apostrophes, Sonnet ≈ Opus. Document the apostrophe constraint or fall back to Opus when app_name contains `'`.
3. **Haiku is not viable for this task.** Two recurring failure modes; only 1/4 cases passes end-to-end.
4. **Self-reported "all tests passed" is insufficient evidence of correctness** — proven again. Sonnet honestly self-reported clean while shipping a broken Android resource. Native builds are non-negotiable.

---

## Running takeaways (for Notion proposal)

- **Native build tooling is load-bearing.** Confirmed across Experiments 4 + 6: only `flutter build apk/ios` catches Podfile structural bugs and Android XML escape bugs.
- **AI self-reports are not trustworthy.** Haiku claimed ✅ while shipping broken Podfile (Exp 4). Sonnet claimed ✅ while shipping broken Android resource (Exp 6). Two independent models, same failure mode of self-reporting.
- **Opus is empirically reliable.** N=6 runs across diverse params, 0 failures. Handles cross-format escaping (Dart + XML + Ruby), distinguishes template-internal vs third-party imports, surfaces semantic implications of codegen flags.
- **Sonnet is the cost/quality tradeoff candidate.** ~5× cheaper per run than Opus, matches Opus on standard params, but apostrophe in app_name surfaces an Android XML escape bug Sonnet doesn't catch. Defensible recommendation: Sonnet default + Opus fallback for app_names with special characters.
- **Haiku is not recommended for this task.** Two distinct failure modes both reproducible across runs.
- **Variance within a single model is real.** Sonnet: 1085s (Exp 1) vs 128s (Exp 4) on same prompt. Doesn't affect correctness but affects "fast vs slow model" claims.
- **Recommendation crystallized:** Opus primary for production-critical generation, Sonnet allowed for cost-sensitive generation with documented apostrophe constraint, Haiku NOT recommended.
- **Harness engineering still NOT required for v1.** Opus passes all observed param combinations. Sonnet's single failure mode is documented and avoidable. Harness becomes valuable only if we adopt Sonnet as default and want to close the Android-XML apostrophe gap automatically.
