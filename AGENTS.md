# AGENTS.md

Agent guide for this Roblox + Rojo repository.
Use this file as the operating baseline for automated coding agents.

## Project Setup

- Project type: Roblox game source synced with Rojo.
- Rojo project file: `default.project.json`.
- Current source mapping:
  - `src/ServerScriptService` -> `ServerScriptService`
  - `src/StarterPlayer/StarterPlayerScripts` -> `StarterPlayer/StarterPlayerScripts`
  - `src/ReplicatedStorage` -> `ReplicatedStorage`
- Example scripts currently present:
  - `src/ServerScriptService/Main.server.lua`
  - `src/StarterPlayer/StarterPlayerScripts/Client.client.lua`

## Instruction Priority

When instructions conflict, apply this order:
1. Direct user request.
2. Repository policy files (`AGENTS.md`, `.cursor/rules/*`, `.cursorrules`, `.github/copilot-instructions.md`).
3. Tool-enforced rules (formatter/linter/test tooling when added).
4. Roblox/Luau conventions.

## Build, Run, Lint, and Test Commands

This repo now supports Rojo workflows.
Run commands from repository root.

### Rojo Commands (Current)

- Start live sync server:
  - `rojo serve`
- Start live sync server with explicit project file:
  - `rojo serve default.project.json`
- Build place file from source:
  - `rojo build default.project.json --output "build/MyNewGame.rbxlx"`

Notes:
- `build/` may not exist yet; create it before first build if needed.
- Use `rojo serve` for day-to-day Studio iteration.
- Use `rojo build` for CI/export artifacts.

### Lint/Format Commands (Not Yet Configured)

No Selene/StyLua config files are currently present.
If these tools are added, use:

- Lint (Selene): `selene src`
- Format (StyLua): `stylua src`

### Test Commands (Not Yet Configured)

There is no test framework configured yet (no TestEZ/Lune setup detected).

- Run all tests: N/A currently
- Run a single test: N/A currently

When tests are added, document exact commands here, including single-test filtering.

## Single-Test Guidance (Future Setup)

When a test runner is introduced, this file must include:
- Full-suite command.
- Single test file command.
- Single test case/name filter command.

Recommended future direction (example only, not active yet):
- Lune + TestEZ wrapper script, with file and name filters.

## Code Style Guidelines (Luau / Roblox)

Apply these conventions unless the repo adds stricter formatter/linter rules.

### Imports and Module Usage

- Prefer `local` bindings for required modules/services.
- Keep requires near top of file after service lookups.
- Use clear module boundaries:
  - shared code in `ReplicatedStorage`
  - server-only code in `ServerScriptService`
  - client-only code in `StarterPlayerScripts`
- Avoid circular module dependencies.

### Formatting

- Keep formatting consistent within each file.
- Use readable line lengths (target ~100 chars).
- Use one logical statement per line.
- Keep nested blocks shallow when possible.
- Do not reformat unrelated files in task-focused changes.

### Types

- Use Luau type annotations for public module APIs.
- Add types to complex tables and function signatures.
- Prefer explicit return types for shared/public functions.
- Avoid `any` unless there is no practical typed alternative.

### Naming Conventions

- Module names: `PascalCase` (e.g., `InventoryService`).
- Local variables/functions: `camelCase`.
- Constants: `UPPER_SNAKE_CASE`.
- Roblox instance names should be descriptive and stable.
- Script suffixes should reflect runtime side when useful (`.server.lua`, `.client.lua`).

### Error Handling and Safety

- Validate arguments at module boundaries.
- Use `assert` for programmer errors and invariants.
- Use `pcall` only when failure is expected/recoverable.
- Include context in warnings/errors (module + action).
- Do not silently swallow failures.

### Roblox Architecture Practices

- Keep authoritative gameplay logic on the server.
- Treat all client input as untrusted.
- Validate `RemoteEvent`/`RemoteFunction` payloads server-side.
- Minimize work in hot paths (`Heartbeat`, `RenderStepped`, loops).
- Prefer event-driven flow over polling where practical.

### Testing Expectations

- Add tests when behavior becomes non-trivial.
- Keep tests deterministic and isolated.
- For bug fixes, add coverage reproducing the bug when possible.
- Start with the narrowest test target, then run broader checks.

### Change Scope

- Keep edits minimal and relevant to the request.
- Avoid broad refactors unless explicitly requested.
- Update this file when tooling/commands/conventions change.

## Agent Workflow for This Repo

1. Read `default.project.json` before structural changes.
2. Keep file placement aligned with Rojo mapping.
3. For script changes, validate runtime side (server vs client).
4. Run available validation commands (currently Rojo commands only).
5. Report what ran and what could not run due to missing tooling.

## Cursor and Copilot Rules

At update time, these were not present:
- `.cursor/rules/`
- `.cursorrules`
- `.github/copilot-instructions.md`

If added later:
1. Treat them as high-priority repo instructions.
2. Merge their non-conflicting rules into this file.
3. Prefer concrete rules over generic guidance.

## Maintenance

Keep this file focused on the active stack (Roblox + Rojo).
Remove stale sections when tooling changes.
Add exact lint/test commands immediately when those tools are introduced.
