# AGENTS.md

## Project Intent

`Jisa` is an iOS app for interacting with timezones. The product details are intentionally still open, so prefer small, reversible steps that keep the codebase easy to extend.

## Workflow Rules

- Use conventional commits for every commit message.
- Use `just` as the top-level task runner.
- Put development automation in shell scripts under `scripts/`, and have `justfile` recipes delegate to those scripts.
- When adding or changing automation, update `justfile` and the backing scripts together.
- Prefer validating changes with `just doctor`, `just build`, `just test`, or `just check` before handing work off.

## Xcode Notes

- Main Xcode project: `Jisa.xcodeproj`
- Main scheme: `Jisa`
- Keep user-specific Xcode state out of version control.
