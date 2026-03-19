# AGENTS.md

## Project

Flutter project template using **spec-driven AI generation**. A golden reference project (`sample/`) + markdown specs + a validation pipeline replace traditional Mason/Mustache templates.

## Repo structure

```
sample/          # Golden reference project (source of truth, CI-validated)
specs/           # Generation prompt + architecture rules + validation scripts
```

## Generating a new project

1. Fill in the 7 parameters in `specs/generation-prompt.md`
2. Feed the prompt + `sample/` source code to an AI model
3. AI generates the project into a fresh directory
4. Run `bash specs/validation/validate.sh <project-path>`
5. If validation fails, feed errors back to the AI and re-validate

## Modifying the template

1. Make the change in `sample/` first (real, runnable code)
2. Run `bash specs/validation/validate.sh sample` — must pass
3. If the change involves a non-obvious constraint, update `specs/architecture-rules.md`
4. If the change affects generation parameters or checklist, update `specs/generation-prompt.md`
5. Run validation again to confirm
6. Never commit if validation fails

## Validation

```bash
bash specs/validation/validate.sh sample
```

4 layers: structure, static analysis (`flutter analyze` + `dart format`), architecture invariants, unit tests.

## Key rules

- `sample/` is the sole source of truth for all code patterns — specs only document non-obvious constraints
- Never generate `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `*.mocks.dart`, or `lib/gen/` — these come from `build_runner` / `flutter_gen`
- Domain layer must not import from data or app layers; data must not import from app
- All Dart imports use `package:` format, never relative imports
