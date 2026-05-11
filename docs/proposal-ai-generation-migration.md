# Proposal: Drop Mason — Use `sample/` + AI to Generate Projects

> 💡 **TL;DR**
>
> Replace the Mason brick system (160 files, 6,674 lines) with 1 markdown spec + the existing `sample/` project as the golden reference. AI does the substitution work Mustache used to do.
>
> **Headline:** -96% of the code we maintain (6,674 → 241 lines).
>
> **Validated across N=15 runs** (3 models × 5 cases each), every run judged against the full pipeline (`pub get`, `build_runner`, `analyze`, `test`, `build apk`, `build ios`). Re-validated end-to-end on Opus 4.7 with `/cost`-confirmed token accounting.
>
> **Cost:** measured **$1.99/run avg** (~2.4M tokens/run, range $0.81–$3.70 / 0.66M–5.0M tokens) on Opus 4.7 API list price. Subscription cost: **$0 marginal** on Max ($100+) / Team Claude Code plans. Per-run 5h-window usage: **~2% on Max 5×** (measured), **~10% on Pro** (extrapolated).
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

## When AI gets it wrong

Two independent models self-reported "all tests passed" while shipping artifacts that fail `flutter build`. Only the native build caught them.

**Haiku's iOS Podfile** (reproduced N=3 runs) — claimed the `GCC_PREPROCESSOR_DEFINITIONS` block was removed, actually left an orphan `]`:

```ruby
      # 'PERMISSION_CRITICAL_ALERTS=1'
      ]                                    ← orphan closing bracket
    end
```

`pod install` fails: `Invalid Podfile file: syntax error, unexpected ']'`. `flutter test` doesn't catch it.

**Sonnet's Android XML** on `app_name = "Bob's Dashboard"` — fixed Dart strings (single → double quotes), missed the unescaped `'` in Gradle's auto-generated `gradleResValues.xml`. Only `flutter build apk` exposes it.

**Lesson:** trust the build, not the self-check. Run `flutter build apk && flutter build ios` on every output.

---

## Recommendation

- **Production: Claude Opus 4.7.** Use when correctness > cost.
- **Cost-sensitive: Claude Sonnet 4.6.** Falls back to Opus if `app_name` contains an apostrophe.
- **⚠ Not recommended: Claude Haiku 4.5.** Two reproducible failure modes; self-reports clean while shipping broken artifacts.

The workflow isn't locked to one vendor — teammates can pick whichever AI they pay for. The gate is the same regardless: `flutter build apk && flutter build ios` before trusting output.

---


## Cost & throughput (measured)

We re-ran all 5 Opus 4.7 cases capturing Anthropic's `/cost` accounting before and after each session — three independent measurements per run (`/cost` $, JSONL token extractor, 5h window % delta).

**Summary per case:**

| Case | Total tokens | `/cost` $ | 5h window Δ% (Max 5×) | Build pipeline |
|---|---:|---:|---:|:---:|
| baseline | 2.83M | $2.32 | +2% | ✅ 7/7 |
| perms | 0.66M | $0.81 | +2% | ✅ 7/7 |
| apostrophe | 5.0M | $3.70 | +3% | ✅ 7/7 |
| longname | 1.8M | $1.71 | +2% | ✅ 7/7 |
| norename | 1.47M | $1.39 | +1% | ✅ 7/7 |
| **Avg** | **2.4M** | **$1.99** | **+2%** | **35/35** |

**Token breakdown per case** (from `/cost` — input / output / cache_write / cache_read):

| Case | Input | Output | Cache write | Cache read | Total |
|---|---:|---:|---:|---:|---:|
| baseline | 569 | 14.6k | 88.3k | 2.80M | 2.90M |
| perms | 526 | 9.1k | 45.1k | 600.7k | 655.4k |
| apostrophe | 590 | 21.6k | 112.3k | 4.90M | 5.03M |
| longname | 654 | 12.9k | 88.5k | 1.70M | 1.80M |
| norename | 539 | 12.0k | 57.7k | 1.40M | 1.47M |
| **Avg** | **576** | **14.0k** | **78.4k** | **2.28M** | **2.37M** |

Cache reads dominate volume (~95% of tokens) but are priced at 0.1× input rate ($0.50/M for Opus 4.7), so cost is bounded by output and cache writes — not raw token count.

**Headline:** ~$2/run on API list, ~2% of 5h window per run on Max 5×.

| Plan | Price/mo | % of 5h window per run | ~Runs / window |
|---|---:|---:|---:|
| Pro | $20 | ~10% (extrapolated) | ~10 |
| Max 5× | $100 | **~2% (measured)** | ~45 |
| Max 20× | $200 | ~0.5% (extrapolated) | ~180 |
| API direct | — | n/a (per-token billing) | unlimited |

> Only Max 5× is measured. Pro and Max 20× are estimates based on Anthropic's plan-tier multipliers — Anthropic doesn't publish exact quotas.

Reproducibility scripts: [`scripts/benchmark/`](https://github.com/nimblehq/flutter-templates/tree/feature/ai-generation-migration/scripts/benchmark) — `setup-opus-bench.sh`, `verify-opus-tokens.sh`, `extract-tokens.py`.


---

> 💡 **"Did you consider a build-retry harness?"** Yes. Data didn't justify it for v1 (Opus 5/5, Sonnet 4/5 with one documented constraint). The verify pipeline is already the harness. Design preserved in [`experiments-log.md`](https://github.com/nimblehq/flutter-templates/blob/feature/ai-generation-migration/docs/experiments-log.md) if we change our mind.

---

## What we lose / What we gain

| What we lose | Mitigation |
|---|---|
| Typed prompted inputs (`mason make` walks you through values) | Spec file has inline constraints; wrong input fails fast |
| Bundled one-command invocation | Verify step runs native Flutter tooling we'd run anyway |
| Generation is no longer free (AI tokens cost money) | **$1.99/run avg** (~2.4M tokens/run) on Opus 4.7 API list, range $0.81–$3.70. **$0 marginal** on Max ($100+) / Team subscriptions; **~10 runs per 5h window on Pro ($20)** (extrapolated). |
| Deterministic output (Mason: same inputs → byte-identical files every run) | AI is non-deterministic — variance is in style, comments, and file count, not in correctness. `flutter build apk/ios` validates regardless. |

| What we gain | Concrete |
|---|---|
| -96% template system size | 6,674 → 241 lines |
| Entire commit class removed | 42 "Generate bundle" commits to date → 0 going forward |
| `sample/` becomes a real Flutter project | You can `flutter run sample/` and use the actual app. |

---

> 💡 **Scope reminder:** this proposal covers the generation phase only. Out of scope (separate tickets if/after this lands): the optional build-retry harness, additional sample variants (different architectures, library presets like Firebase/Sentry), and Claude Code skills integration.

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
