# Proposal: Drop Mason — Use `sample/` + AI to Generate Projects

> 💡 **TL;DR**
>
> Replace the Mason brick system (160 files, 6,674 lines) with 1 markdown spec + the existing `sample/` project as the golden reference. AI does the substitution work Mustache used to do.
>
> **Headline:** -96% of the code we maintain (6,674 → 241 lines).
>
> **Validated across N=15 runs** (3 models × 5 cases each), every run judged against the full pipeline (`pub get`, `build_runner`, `analyze`, `test`, `build apk`, `build ios`).
>
> **Recommended:** Claude Opus 4.7 (production), Sonnet 4.6 (cost-sensitive, with one documented apostrophe constraint), **not** Haiku 4.5.
>
> **The reliability story:** native `flutter build apk && flutter build ios` is the safety net. Run it every time. Full data: [`experiments-log.md`](https://github.com/nimblehq/flutter-templates/blob/feature/ai-generation-migration/docs/experiments-log.md).

---

## The pain we're solving

We use the template a few times a year — but maintain it every few weeks.

**Every Mason template change requires 5 mechanical steps across 3 artifacts:**

1. Edit the brick (Mustache-mixed Dart)
2. Regenerate the Mason bundle
3. Regenerate the `sample/` project
4. Verify all 3 line up
5. Commit brick + bundle + sample together

The cost shows up in the commit log: **42 "Generate bundle / sample" commits** to date, all with zero functional change — pure regeneration tax (`git log --all | grep -ic generate` confirms).

Onboarding adds a second tax. New contributors must learn 5 Mason-specific concepts (CLI, Mustache, `brick.yaml`, hooks, bundle regeneration) that don't transfer to anything else they touch in Flutter.

**Under AI generation:** `sample/` IS the source of truth — no separate bundle. Contributors edit a normal Flutter project. Both taxes go to zero.

---

## Before / after

| | Mason era | AI era |
|---|---|---|
| Template system size | **6,674 lines / 160 files** | **241 lines / 2 files** |
| Maintained artifacts | Mustache-mixed Dart bricks, hooks, `mason.yaml`, regenerated bundle | `specs/generation-prompt.md` (184 lines), `.github/workflows/test.yml` (57 lines) |
| Concepts to learn | Mason CLI, Mustache, `brick.yaml`, hooks, bundle regeneration | Paste a markdown file into an AI |
| New architecture added by | Rewriting the brick with new Mustache vars | Creating a sibling sample (`sample-bloc/`, `sample-riverpod/`) |
| Custom validation code | N/A | **0 lines** — native `flutter analyze` / `test` / `build` is the gate |

---

## Maintenance effort, task by task

| When you need to… | Mason era | AI era |
|---|---|---|
| Bump Flutter SDK | Edit brick → regen bundle → regen sample → verify → commit all 3 | Edit `sample/` like any Flutter project, run verify |
| Bump a dependency | Same 5-step ritual | `flutter pub upgrade <pkg>` in `sample/` |
| Switch architectural pattern (e.g. BLoC) | Rewrite brick + new Mustache vars | Create `sample-bloc/` as a sibling sample |
| Fix a bug in generated projects | Fix in brick → regen → sync sample | Fix in `sample/` |
| Onboard a new contributor | Learn Mason CLI, Mustache, `brick.yaml`, hooks, bundle regen | Read `sample/` as a normal Flutter project |

---

## How a teammate uses this

1. Check out the `feature/ai-generation-migration` branch. Open `specs/generation-prompt.md`.
2. Edit the 7 parameter values at the top.
3. Paste the prompt into an AI (Claude, ChatGPT — both work).
4. AI produces a complete Flutter project directory.
5. Verify it builds:
   ```bash
   cd <your_project>
   flutter pub get && dart run build_runner build --delete-conflicting-outputs
   flutter analyze && flutter test
   flutter build apk --debug --flavor staging -t lib/main.dart
   flutter build ios --debug --no-codesign --flavor staging -t lib/main.dart
   ```

If all green, ship.

---

## Does it actually work?

We ran **15 generations** with the full build pipeline gate, across 3 models × 5 cases each (1 standard params + 4 edge cases — apostrophe in app name, long nested package, alternate codegen, permission_handler conditional).

**Aggregate scorecard:**

| Model | Cases tested | Cases full-pass | Stage pass rate | Failure modes |
|---|---|---|---|---|
| **Opus 4.7** | 5 | **5/5** | **35/35** | none observed |
| **Sonnet 4.6** | 5 | 4/5 | 34/35 | Android XML escape on `'` in app name |
| **Haiku 4.5** | 5 | 1/5 | 28/35 | Podfile orphan `]` (recurring), Dart apostrophe (catastrophic) |

Per-round detail, methodology, and variance analysis: [`experiments-log.md`](https://github.com/nimblehq/flutter-templates/blob/feature/ai-generation-migration/docs/experiments-log.md).

---

## Why native builds are the safety net

> 💡 The single most important empirical result. Two independent models honestly self-reported "all 4 tests passed" while shipping artifacts that fail `flutter build`. The only thing that caught either was running the actual native build.

### Exhibit A — Haiku's iOS Podfile orphan `]`

Haiku's report claimed: ✅ "Removed entire `GCC_PREPROCESSOR_DEFINITIONS` block from `ios/Podfile`."

Haiku's actual `ios/Podfile`:

```ruby
# ... 11 orphan comment lines from inside the deleted block ...
      # 'PERMISSION_CRITICAL_ALERTS=1'
      ]                                    ← ORPHAN closing bracket
    end
  end
end
```

`pod install` fails with `Invalid Podfile file: syntax error, unexpected ']'`. **Reproduced N=3 times across runs.** `flutter build ios` catches it instantly; `flutter test` doesn't.

### Exhibit B — Sonnet's Android XML apostrophe (one-line summary)

On `app_name = "Bob's Dashboard"`, Sonnet correctly fixed Dart strings (single → double quotes) but missed the Android resource side. The unescaped `'` in Gradle's auto-generated `gradleResValues.xml` fails AAPT compilation. **Only `flutter build apk` exposes it** — `flutter test` doesn't compile Android resources. Opus handled both Dart and Android XML on the same case.

### The lesson

**Don't trust the AI's self-check. Trust the actual build.** AI generation does not eliminate the "this can ship broken" failure mode — it just shifts which model causes it. Running `flutter build apk && flutter build ios` on every output is the entire reliability story for v1.

---

## Recommendation

- **Production: Claude Opus 4.7.** Use when correctness > cost.
- **Cost-sensitive: Claude Sonnet 4.6.** Falls back to Opus if `app_name` contains an apostrophe.
- **⚠ Not recommended: Claude Haiku 4.5.** Two reproducible failure modes; self-reports clean while shipping broken artifacts.

The workflow isn't locked to one vendor — teammates can pick whichever AI they pay for. The gate is the same regardless: `flutter build apk && flutter build ios` before trusting output.

---

> 💡 **"Did you consider a build-retry harness?"** Yes. Data didn't justify it for v1 (Opus 5/5, Sonnet 4/5 with one documented constraint). The verify pipeline is already the harness. Design preserved in [`experiments-log.md`](https://github.com/nimblehq/flutter-templates/blob/feature/ai-generation-migration/docs/experiments-log.md) if we change our mind.

---

## What we lose / What we gain

| What we lose | Mitigation |
|---|---|
| Typed prompted inputs (`mason make` walks you through values) | Spec file has inline constraints; wrong input fails fast |
| Bundled one-command invocation | Verify step runs native Flutter tooling we'd run anyway |
| Generation is no longer free (AI tokens cost money) | Default path is Claude Code on existing team subscriptions — $0 marginal cost. |

| What we gain | Concrete |
|---|---|
| -96% template system size | 6,674 → 241 lines |
| Entire commit class removed | 42 "Generate bundle" commits to date → 0 going forward |
| `sample/` becomes a real Flutter project | You can `flutter run sample/` and use the actual app. |

---

## Decision needed

This is a **POC**, not a merge candidate. PR #290 exists so you can read the actual code and run it locally — it won't be merged as-is.

**What we're deciding:** does the team agree with the direction (Mason → AI + `sample/` as source of truth)?

If yes, we'll roll it out via clean follow-up tickets/PRs:
- Split PR #290 into reviewable chunks
- Polish `specs/` to land-quality
- Update README + onboarding docs
- Ship behind a transition period where Mason still works

**How to approve the direction:** ✅ on Slack thread
**How to block / raise concerns:** reply on the Slack thread with the specific issue

---

For the skeptical reviewer: full per-experiment record, methodology, variance analysis, and harness design are in [`experiments-log.md`](https://github.com/nimblehq/flutter-templates/blob/feature/ai-generation-migration/docs/experiments-log.md). Reproducibility scripts under [`scripts/benchmark/`](https://github.com/nimblehq/flutter-templates/tree/feature/ai-generation-migration/scripts/benchmark).
