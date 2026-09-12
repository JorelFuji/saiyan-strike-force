# Vulcan Fitness

Flutter strength-training app for self-coached lifters who plan their own programs and need a fast, precise, distraction-free tool to build workouts, schedule them, log sessions, and review history.

**Platform:** iOS & Android (mobile only)  
**Package:** `vulcan`  
**Stance:** Local-first on device. Encryption at rest (SQLCipher) is the v1 data contract — see `docs/vulcan/data-model.md`. Optional write-only sync to Apple HealthKit / Google Health Connect. No cloud account or cross-device sync in v1.

## Docs

Product and architecture specs live under [`docs/vulcan/`](docs/vulcan/). Agent guidance: [`AGENTS.md`](AGENTS.md) (always-on) and [`.claude/skills/`](.claude/skills/) (on demand).

## Development

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```
