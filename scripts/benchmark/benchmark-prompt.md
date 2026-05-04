# Canonical benchmark prompt

Paste this exactly into every benchmark session. Do not modify between runs —
the only thing that varies is the model flag (`claude --model X`) and the
worktree you `cd` into (which has its own pre-set Parameters block).

---

```
Read specs/generation-prompt.md and follow it exactly to generate a new Flutter project.

The Parameters block at the top of that file has already been filled in for this run — do NOT change them.

Use sample/ as the reference architecture. Copy every file from sample/ into the output directory, applying the substitutions defined in the spec.

Output path: the directory matching this worktree under output/m_runs_models/ (already created by the setup script).

After generation, verify your work by running:
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  flutter analyze
  flutter test

Report any failures honestly. Do not skip the verification commands.
```

---

## Why this matters

If I hand you a different prompt each session, the benchmark measures
"model + prompt phrasing" — not the model. The Round 1 and Round 2 runs
used roughly the same shape but weren't pinned to a file, which is a
methodology hole.

For Round 3 (this 8-run multi-model edge sweep), use ONLY the prompt above.
