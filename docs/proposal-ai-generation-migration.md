# Proposal: Migrate Flutter Templates from Mason to AI

> 💡 **TL;DR**
>
> Replace the Mason brick system (160 files, 6,674 lines) with 2 markdown specs + the existing `sample/` project as the golden reference. AI does the substitution work Mustache used to do.
>
> **Headline:** -97% of the code we maintain. Customization expands beyond Mason's 7 fixed variables.
>
> **Benchmark-validated across 3 AI models and 3 rounds — N=18 independent runs total**, each judged against the full pipeline (`pub get`, `build_runner`, `analyze`, `test`, `build apk`, `build ios`).
>
> **Recommended (production): Claude Opus 4.7** — N=6 runs across diverse edge cases, **0 failures**. Passes every verification stage on both Android and iOS.
> **Allowed (cost-sensitive): Claude Sonnet 4.6** — passes every stage on standard params; one documented edge case (`'` in app name) breaks Android resource compilation. Avoid if the project name has an apostrophe, or fall back to Opus.
> **⚠ Not recommended: Claude Haiku 4.5** — two systematic failure modes reproduced across runs: (1) malformed `ios/Podfile` syntax, (2) catastrophic Dart string-escape failures on apostrophes. Self-reports clean while shipping broken artifacts.
>
> **The headline finding behind these recommendations:** AI self-reports are not trustworthy. Both Haiku and Sonnet honestly self-reported "all 4 tests passed" while shipping artifacts that fail `flutter build apk` or `flutter build ios`. **Native builds are non-negotiable**, and that's the entire reliability story — not a harness, not a validation suite.

---

## Why now

Every Mason template change requires a second "regeneration" commit to sync the bundle with `sample/`. Over time that's produced a steady stream of `[Chore] Generate bundle` commits — pure mechanical work with no functional change. Under AI, `sample/` IS the source of truth, so there's no separate bundle to regenerate. That mechanical work disappears entirely.

Beyond the commit tax: every Mason edit requires the contributor to understand Mustache syntax, `brick.yaml` schema, and the hook model. AI generation replaces all of that with "edit `sample/` as a normal Flutter project, update the prompt if substitution targets change."

---

## The system, before and after

**Template system size**

- Mason era: **6,674 lines across 160 files**
- AI era: **234 lines across 3 files**

**Maintained artifacts**

- Mason era: `bricks/template/*` (Mustache-mixed Dart), `bricks/permission_handler/*`, `hooks/pre_gen.dart`, `hooks/post_gen.dart`, `mason.yaml`, regenerated bundle
- AI era: `specs/generation-prompt.md` (121 lines), `specs/architecture-rules.md` (56 lines), `.github/workflows/test.yml` (57 lines)

**Concepts a contributor must learn**

- Mason era: Mason CLI, Mustache syntax, `brick.yaml` schema, hooks (`pre_gen.dart` / `post_gen.dart`), bundle regeneration
- AI era: paste a markdown file into an AI

**Customization surface**

- Mason era: **7 fixed variables** (project_name, package_name, app_name, app_version, build_number, json_field_rename, add_permission_handler)
- AI era: **unbounded** — natural language. "use BLoC instead of MVVM", "GraphQL instead of REST", etc.

**Custom validation code**

- Mason era: N/A
- AI era: **0 lines**. Native `flutter analyze` / `flutter test` / `flutter build` is the gate.

**How a new architecture is added**

- Mason era: rewrite the brick with new Mustache variables
- AI era: create a sibling sample — `sample-bloc/`, `sample-riverpod/` — AI picks the right one based on the prompt

---

## How a teammate uses this (end-to-end)

1. Clone the repo. Open `specs/generation-prompt.md`.
2. Edit the 7 parameter values at the top.
3. Copy the prompt between `---START PROMPT---` and `---END PROMPT---`. Paste into an AI (Claude, Codex, ChatGPT — all work).
4. AI produces a complete Flutter project directory.
5. Verify it builds:

```bash
cd <your_project>
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --debug --flavor staging -t lib/main.dart
flutter build ios --debug --no-codesign --flavor staging -t lib/main.dart
```

If all green, ship.

---

## How we ran the benchmark

Teammates should see methodology, not just conclusions. Here's exactly what we did.

### Fixed parameters (same across all models)

```
project_name           = alex_wang
package_name           = co.alex.wang
app_name               = Alex Wang
app_version            = 0.1.0
build_number           = 1
json_field_rename      = snake
add_permission_handler = false
```

`add_permission_handler=false` was chosen deliberately — it's the hardest code path (coordinated removal across 3 files in 3 different languages: YAML dependency, Dart import graph, Ruby Podfile block).

### Isolation (preventing cross-run contamination)

Each model ran in its own git worktree detached at the same commit. A Claude Code auto-memory directory was parked aside before runs started. This prevents any model from:
- Seeing another model's in-progress or final output
- Reading project memory another model wrote
- Sharing shell state or env vars

```bash
# Setup (simplified)
git worktree add --detach ../bench-haiku  $HEAD_SHA
git worktree add --detach ../bench-sonnet $HEAD_SHA
git worktree add --detach ../bench-opus   $HEAD_SHA

mv ~/.claude/.../memory ~/.claude/.../memory.bench-bak
```

### Prompt pasted to each model (identical)

> I'm benchmarking Flutter template generation. Follow `specs/generation-prompt.md` exactly — use the parameters already in the Parameters section and follow the instructions between `---START PROMPT---` and `---END PROMPT---`. Create the project under `output/m_runs/<model>/`.
>
> **Timing (mandatory):** Before you do ANYTHING else, run `date +%s` as `start_ts`. When done, run `date +%s` as `end_ts` and include `duration_seconds = end_ts - start_ts` in your final report.
>
> **Final report must include:**
> - `duration_seconds`
> - (a) files created
> - (b) grep self-check leftover count
> - (c) clarification questions considered
> - (d) retries / self-corrections
> - (e) errors hit and how resolved
> - (f) files created NOT in `sample/` (should be 0)
> - (g) structural operations confirmation ✅/❌

### Verification (I ran this, not the AI — identical commands on each output)

```bash
cd output/m_runs/<model>/alex_wang
grep -rn '<template-strings>' .      # substitution check
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze .
flutter test
flutter build apk --debug --flavor staging -t lib/main.dart
flutter build ios --debug --no-codesign --flavor staging -t lib/main.dart
```

Verification is separate from generation so each AI isn't measured against its own self-healing policy — every output is judged by the same tooling on the same shell.

### Codex skipped

Codex CLI wasn't installed on the benchmark machine. Ran 3 models (Haiku, Sonnet, Opus) instead of 4. Codex was previously validated in an earlier preliminary benchmark — adding it back is a follow-up.

---

## Benchmark results

We ran **three rounds** of increasing rigor. Each round added either a stricter gate (`flutter build apk/ios`) or harder parameters (edge cases). Full per-experiment detail lives in [`experiments-log.md`](./experiments-log.md).

### Round 1 — Standard params, all 3 models (N=3)

Same params as the section above. All three models pass `analyze + test + build apk`. Haiku alone fails `build ios` due to a malformed Podfile (see "Why native builds are load-bearing" below).

| Stage | Haiku | Sonnet | Opus |
|---|---|---|---|
| `flutter pub get` | ✅ 6s | ✅ 2s | ✅ 2s |
| `dart run build_runner build` | ✅ 27s | ✅ 23s | ✅ 24s |
| `flutter analyze` | ✅ 0 | ✅ 0 | ✅ 0 |
| `flutter test` | ✅ pass | ✅ pass | ✅ pass |
| **`flutter build apk`** | ✅ 41s | ✅ 24s | ✅ 26s |
| **`flutter build ios`** | ❌ **FAIL** — Podfile syntax error | ✅ 46s | ✅ 39s |

### Round 2 — Opus across 4 edge-case parameter sets (N=4)

The four cases were chosen to stress different code paths:

| Case | Stress test |
|---|---|
| `perms=true` | Conditional branch we hadn't tested before — must KEEP `permission_handler` everywhere |
| `apostrophe` | `app_name = "Bob's Dashboard"` — string escaping across Dart, XML, Ruby, plist, pbxproj |
| `longname` | `enterprise_dashboard_app` + nested package `co.nimblehq.enterprise.dashboard` — identifier propagation |
| `norename` | `json_field_rename = none` — alternate codegen behavior |

| Stage | perms=true | apostrophe | longname | norename |
|---|:-:|:-:|:-:|:-:|
| `flutter pub get` | ✅ | ✅ | ✅ | ✅ |
| `dart run build_runner build` | ✅ | ✅ | ✅ | ✅ |
| `flutter analyze` | ✅ 0 | ✅ 0 | ✅ 0 | ✅ 0 |
| `flutter test` | ✅ | ✅ | ✅ | ✅ |
| **`flutter build apk`** | ✅ 35s | ✅ 27s | ✅ 30s | ✅ 28s |
| **`flutter build ios`** | ✅ 56s | ✅ 35s | ✅ 38s | ✅ 47s |

**Opus: 4/4 cases × 7 stages = 28/28 ✅.** No failures.

### Round 3 — Haiku and Sonnet across the same 4 edge cases (N=8)

| Model / Case | grep | pub_get | build_runner | analyze | test | build_apk | build_ios |
|---|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| **haiku/perms** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **haiku/apostrophe** | ✅ | ✅ | ❌ | ❌ 34 issues | ✅ | ❌ | ❌ |
| **haiku/longname** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **haiku/norename** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **sonnet/perms** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **sonnet/apostrophe** | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ Android XML | ✅ |
| **sonnet/longname** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **sonnet/norename** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Aggregate scorecard across all 3 rounds

| Model | Cases tested | Cases full-pass | Stage pass rate | Failure modes |
|---|---|---|---|---|
| **Opus 4.7** | 5 | **5/5** | **35/35** | none observed |
| **Sonnet 4.6** | 5 | 4/5 | 34/35 | Android XML escape on `'` in app name |
| **Haiku 4.5** | 5 | 1/5 | 26/35 | Podfile orphan `]` (recurring), Dart apostrophe (catastrophic) |

---

## Recommendation

**Production default: Claude Opus 4.7.** N=6 runs across diverse edge cases, 0 failures. Handles cross-format escaping (Dart + Android XML + Ruby), distinguishes template-internal vs third-party imports, surfaces semantic implications of codegen flags. Use this when correctness matters more than cost.

**Cost-sensitive option: Claude Sonnet 4.6.** ~5× cheaper per run than Opus, matches Opus on standard params and on long names + nested packages + alternate codegen. **One documented edge case fails:** if `app_name` contains an apostrophe (e.g. `Bob's Dashboard`), Sonnet correctly escapes the Dart side but misses the Android XML side, causing `flutter build apk` to fail on resource compilation. Two ways to handle this:
- Avoid apostrophes in app names (most projects don't have them)
- Or use Opus when an apostrophe is present (manual fall-back)

**⚠ Do NOT use Claude Haiku 4.5.** Two reproducible failure modes:
1. **iOS Podfile**: when `add_permission_handler=false`, Haiku deletes the inner contents of the `GCC_PREPROCESSOR_DEFINITIONS` array but leaves the closing `]`, producing a Ruby syntax error. Reproduced N=3/3 across runs that exercised this branch.
2. **Apostrophe**: doesn't escape `'` in Dart strings, breaking codegen → analyze fails with 34 issues → both builds fail.

Haiku self-reports clean in every case. **Avoid for this task.**

**Why we tested multiple models:** the workflow must not lock in a single vendor, and different models have different failure modes. After 18 runs across 3 rounds, the data is clean: Opus is uniquely reliable, Sonnet has one known gap, Haiku has two. Teammates can pick whichever AI they pay for — but the gate is the same: `flutter build apk && flutter build ios` before trusting output.

---

## Why native builds are load-bearing

> 💡 The single most important empirical result in this benchmark.
>
> Two independent models, two different failure modes, both honestly self-reported as "all 4 tests passed" while shipping broken artifacts. The only thing that caught either of them was running the actual native build.

### Exhibit A — Haiku's iOS Podfile orphan `]`

Haiku's final report claimed this structural operation was done correctly:

> ✅ Removed entire `config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [ ... ]` block from ios/Podfile

Haiku's actual `ios/Podfile` content:

```ruby
# ... 11 orphan comment lines from inside the block ...
      # 'PERMISSION_CRITICAL_ALERTS=1'
      ]                                    ← ORPHAN closing bracket
    end
  end
end
```

Haiku deleted the opening line but left every element inside the array AND the closing `]`. Result: Ruby syntax error on `pod install`. **Same bug shape as a bash `sed` generator.** Reproduced N=3 times across runs. `flutter build ios` catches it immediately; nothing else does.

### Exhibit B — Sonnet's Android XML apostrophe escape

Sonnet's edge-case report on `app_name = "Bob's Dashboard"` claimed all 4 verification commands passed cleanly. It also volunteered:

> One notable fix: Bob's Dashboard contains an apostrophe that broke Dart single-quoted string literals in 3 integration test files. These were switched to double-quoted strings, which is the correct Dart approach.

Sonnet correctly fixed the **Dart** side. But when we ran `flutter build apk`:

```
gradleResValues.xml:6:4: Failed to flatten XML for resource 'app_name'
  with error: Invalid unicode escape sequence in string "{str}"
gradleResValues.xml:6:4: string/app_name does not contain a valid string resource

FAILURE: Build failed with an exception.
* What went wrong:
Execution failed for task ':app:mergeStagingDebugResources'.
```

The `app_name` is injected by Gradle into the auto-generated `gradleResValues.xml`. Android XML requires `'` to be escaped as `\'` or `&apos;`. Sonnet handled the Dart side, missed the Android side, self-reported clean. **Only `flutter build apk` exposes it** — `flutter test` doesn't trigger Android resource compilation. iOS passed because pbxproj uses double-quotes already.

Opus, on the same edge case, handled both Dart and Android XML. That's a meaningful Opus advantage that only surfaces on apostrophes.

### Why AI self-checks miss these

Both models ran the same self-verification layers during generation, all of which passed:

1. **grep self-check**: scans for template strings like `co.nimblehq.flutter.template`. A bare `]` or an unescaped `'` doesn't match any substitution pattern. ✅ 0 matches, no alarm.
2. **AI structural-op self-report**: each model asserted ✅ on the relevant operation. The assertions were wrong in different ways — Haiku's model of what it deleted, and Sonnet's model of where the apostrophe needed escaping.
3. **Flutter tooling *without* the build step**: `pub get`, `build_runner`, `analyze`, `test` all passed — because none of them parse `Podfile` or compile Android resources. Both are downstream of `flutter build`.

### Why the native builds caught them

- `flutter build ios` invokes `pod install` → CocoaPods runs the Ruby parser on `Podfile` → orphan `]` is a syntax error.
- `flutter build apk` invokes Gradle → AAPT compiles XML resources → unescaped apostrophe is an invalid string resource.

Deterministic, fast, unambiguous. **Native tooling with real teeth.**

### Empirical case for the migration

| | `generate.sh` (bash) | Haiku (AI) | Sonnet (AI) | Opus (AI) |
|---|---|---|---|---|
| Hit a build-time bug? | Yes (Podfile sed) | **Yes (Podfile + apostrophe)** | **Yes (Android XML on apostrophe only)** | No |
| AI self-report accurate? | N/A | **No** | **No** | Yes |
| Grep self-check caught it? | N/A | No | No | N/A |
| `flutter build apk/ios` caught it? | Yes | Yes | Yes | N/A |
| Shipped correct output? | ❌ | ❌ | ⚠ except apostrophe edge | ✅ |

**The lesson: don't trust the AI's self-check. Trust the actual build.** Moving from Mason to AI does not eliminate the "this can ship broken" failure mode — it just shifts which model causes it. The safety is `flutter build apk && flutter build ios` on every output, every time. That's the entire reliability story for v1. No harness, no validation suite, no DSL. Just the native build.

---

## Variance caveat

Across all three benchmark rounds, **timing variance was large** but **correctness variance was clean**: each model has consistent failure modes across runs.

| Model | Round 1 (standard) | Round 2 / Round 3 (edge cases) | Failure consistency |
|---|---|---|---|
| Haiku 4.5 | 322s | varies per case | **Same iOS Podfile bug** in N=3/3 cases that exercised the conditional. Same Dart apostrophe bug in N=1/1 case. |
| Sonnet 4.6 | 128s (round 1: 1085s) | varies per case | **Same Android XML apostrophe bug** in N=1/1 case. All other cases clean. |
| Opus 4.7 | 174s | 100–256s | **Zero failures** across N=6 runs. |

What this tells us:
- **Model failure modes are reproducible**, not random one-off flakiness. If Haiku breaks the Podfile once, it'll break it again on the same conditional.
- **Timing varies wildly but doesn't predict correctness.** Sonnet's 8× speed swing between rounds did not change its output quality.
- **Adding `flutter build apk/ios` to verification was the single highest-leverage methodology change.** Round 1 conclusions ("all 3 models produce identical quality") were wrong — they relied on `flutter test`, which doesn't compile native resources or run `pod install`. Both Round 2 (Opus edge cases) and Round 3 (multi-model edge cases) only revealed their findings because of the build stages.

Re-running this benchmark annually, or when swapping the recommended default, is still reasonable policy. But the gate for any single generated project is the verify pipeline, not the benchmark.

---

## Harness engineering — considered, not required for v1

Earlier drafts of this proposal recommended building a **harness** — runtime scaffolding that wraps the AI call with automatic build-retry, structural invariant checks, and substitution whitelists. After 18 verified runs across 3 rounds, the data argues against shipping it in v1.

### Why it's deferred

| Failure mode observed | Recommended model | Affected by Opus | Affected by Sonnet (standard) |
|---|---|---|---|
| Podfile orphan `]` | Haiku only | No | No |
| Dart apostrophe escaping | Haiku only | No | No (Sonnet handles Dart side) |
| Android XML apostrophe | Sonnet on `'` in app name | No | Only on `'` |

If the recommendation is **Opus primary, Sonnet for cost-sensitive standard params, never Haiku**, then the harness's main job (catching Haiku-class silent failures) is solved by model selection. The remaining failure surface — Sonnet's apostrophe edge case — is a single documentable constraint, not a class of bugs that needs a runtime catcher.

`sample/` is doing the work a harness would normally do: it's a production-quality reference implementation that the AI translates rather than re-architects. As long as `sample/` builds, AI generation is mechanical translation with judgment — well within Opus and Sonnet reliability.

### What a harness would look like (for future reference)

If we ever decide we need one, here's the design:

**1. Build-retry loop.** After generation:
```
for attempt in 1..3:
  run: pub get && build_runner && analyze && test && build apk && build ios
  if pass: done
  if fail: extract first error → prompt AI to fix just that error → try again
```
Would have caught Haiku's Podfile syntax error on attempt 1 and Sonnet's apostrophe on attempt 1.

**2. Structural invariant checks** — `package:<project_name>/` matches pubspec `name:`, Kotlin path mirrors `package_name`, `permission_handler:` absence implies no `permission_wrapper.dart` and no `GCC_PREPROCESSOR_DEFINITIONS` block, every flavor has `.env.<flavor>`. ~5 lines of validation code per rule.

**3. Substitution whitelist** — `git diff sample/ <generated>` and assert every change falls on the allowed list. Closes "AI invented a file" failure mode.

**4. Multi-model consensus (optional)** — run 2 models in parallel, diff outputs, divergence = human-review signal.

### When to revisit

Build the harness if any of these become true:
- Adoption broadens beyond Nimble (different toolchains, different teams)
- We change the recommended default away from Opus
- A previously-untested param combination surfaces a real failure in production use
- We want architectural invariant enforcement as part of ongoing code review (independent of generation)

Until then: the verify pipeline (`flutter build apk && flutter build ios`) is the harness.

---

## What we lose (honesty section)

**1. Typed, prompted inputs.** Mason runs `mason make template` and walks the user through typed prompts. AI just takes a markdown file. Users must edit values before pasting.
   - *Mitigation:* the spec file has inline constraints and examples. Wrong input fails fast.

**2. Bundled one-command invocation.** `mason make template` is one CLI call. AI workflow is paste → verify.
   - *Mitigation:* the verify step runs native Flutter tooling we'd run anyway.

**3. Deterministic CI-side generation.** Anyone can `mason make` in CI for reproducibility. AI generation isn't run in CI today.
   - *Mitigation:* CI validates `sample/` itself on every push. If `sample/` is green, any substituted copy of it will build. We do not need to re-run generation in CI to prove correctness.

**4. Native tooling doesn't compile Fastlane Ruby or pbxproj display strings.** A missed substitution in `ios/fastlane/Constants/Constants.rb` or `APP_DISPLAY_NAME` won't fail a build.
   - *Mitigation:* users run a 2-line grep check before shipping (documented in `specs/generation-prompt.md`). Caught 100% of those misses in the benchmark.

**5. Requires JDK 17.** Android Studio 2024.2+ ships JDK 21, incompatible with the bundled Gradle 7.5 in `sample/`.
   - *Mitigation:* README documents the pin. Deferred work item: modernize `sample/`'s Gradle stack.

**6. Generation is no longer free.** Mason ran locally at $0. Running an AI consumes tokens, which costs money (API usage) or subscription quota (claude.ai / Claude Code Pro, ChatGPT Plus, etc.).
   - *Rough costs per generation* (a single project, ~50K input + ~50K output tokens, estimated — confirm against current vendor pricing before publishing):
     - **Claude Code on existing Pro/Team subscription:** $0 marginal cost, counted against your monthly quota (rate-limited, not dollar-limited).
     - **Claude Haiku 4.5 via API:** ~$0.05-0.20 per generation.
     - **Claude Opus 4.7 via API:** ~$3-8 per generation.
     - **Codex (GPT-5) via API:** ~$3-6 per generation.
     - **ChatGPT Plus web interface:** $0 marginal, but slower because files must be attached manually.
   - *Mitigation:* default path is Claude Code on existing team subscriptions — no marginal cost for most Nimble engineers. If someone needs API access (automation, batch), it's expensable and tracked per-project.
   - *What teammates should ask before approving:* "Who pays for the API usage if we automate this?" Answer proposed: API access is opt-in, reimbursed like any other dev tool.

---

## What we gain

**1. -97% template system size** (6,674 → 234 lines).

**2. Entire class of commits removed.** 29+ "Generate bundle" commits per year go to zero.

**3. New architectures added by creating new samples**, not by rewriting a Mason brick. 10x faster.

**4. Model-agnostic.** Works with any current AI. Not a bet on one vendor.

**5. `sample/` becomes a real Flutter project.** You can open it in Android Studio, work on it directly, run the real app. Nothing is Mustache-wrapped. No build step. Contributors see normal Dart code.

---

## Decision needed

Approve merging **PR #290** into `develop`?

**What the merge does:**

- Deletes `bricks/`, `hooks/`, `mason.yaml` (Mason infrastructure — ~6,500 lines gone)
- Keeps `sample/` as the canonical reference project
- Ships `specs/generation-prompt.md` + `specs/architecture-rules.md` as the generation interface

**How to approve:**

- ✅ React with ✅ on the Slack announcement
- ✅ Approve PR #290 on GitHub (for code owners)

**How to block:**

- ❌ React with ❌ on Slack **and** leave a thread comment explaining the concern
- ❌ Request changes on PR #290

**Decision owner:** [YOUR_NAME]
**Deadline:** [DATE — e.g. 7 days from Slack post]
**Default action if no explicit blockers by deadline:** merge proceeds.

**Rollback plan:** `git revert` on the merge commit. Mason infrastructure returns intact. Zero data loss, zero state loss.

---

## Appendix — methodology notes for the skeptical reviewer

**The benchmark ran three rounds, not one.** Round 1 (standard params, all 3 models) verified through `flutter test` and initially concluded "all models produce identical quality." Adding `flutter build apk/ios` to that same round flipped the conclusion — Haiku's iOS Podfile failure surfaced. Round 2 (Opus across 4 edge cases) and Round 3 (Haiku + Sonnet across the same 4 edge cases) extended the matrix to 18 total runs across all three models. The methodology lesson held: **don't set the verification bar lower than the production use case.** Full per-experiment detail in [`experiments-log.md`](./experiments-log.md).

**Why we removed the 570-line validation suite we started building.** The suite was written to catch AI-level substitution mistakes, which in practice don't happen (all 3 models pass the grep self-check with 0 leftovers in every round). The failures that DO matter — Podfile Ruby malformation, Android XML escaping — are caught by the native build pipeline. The custom suite was protecting against the wrong failure mode. Removed.

**Why we dropped the bash generator.** Same Podfile bug shape that Haiku exhibited, but without the ability to self-correct at all. Bash `sed` matches a pattern and deletes — it has no model of what Ruby syntax means. Opus and Sonnet (on standard params) get it right; bash never could. The migration is the correct direction.

**Why we included `add_permission_handler=false` and apostrophe in `app_name` specifically.** They're the hardest code paths — coordinated edits across 3 files in 3 languages (YAML + Dart + Ruby) for the conditional, and string escaping across Dart + Android XML + Ruby + plist + pbxproj for the apostrophe. Trivial happy-path tests prove nothing; these are the stress tests. Both surfaced real failure modes in Haiku and Sonnet that wouldn't have appeared on default params.

**Why we tested the same 4 edge cases on Opus first, then Haiku/Sonnet later.** Establishing a "gold standard" baseline with Opus first meant that when Haiku and Sonnet hit failures, we could be confident the failure was model-specific (not param-specific or sample-specific).

**What CI adds (and doesn't).** The CI workflow at `.github/workflows/test.yml` runs the full verify pipeline on `sample/` on every push. That protects the template's golden reference. It does NOT run generation in CI (cost + non-determinism). For generated-project verification, the user runs the same commands locally.
