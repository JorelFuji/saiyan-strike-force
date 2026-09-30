# vulcan_fitness

Offline-first fitness tracker. Product and technical docs live in
[docs/vulcan](docs/vulcan/README.md). Engineering conventions for humans and
agents live in [AGENTS.md](AGENTS.md). The operational status of bounded work
lives in the [issue tracker](ISSUES.md).

## Toolchain

The Flutter SDK is pinned to an exact stable release in [`.fvmrc`](.fvmrc) (currently **3.47.4**,
Dart 3.13.3), and `pubspec.yaml` pins the matching Dart version exactly. CI installs the same
release and refuses to analyze, test, or build under any other SDK.

```sh
fvm install          # fetch the pinned release
fvm use 3.47.4       # link it into this project
fvm flutter pub get
```

Export files include the app version from `VULCAN_APP_VERSION`. CI and release
builds should pass the build name and number with `--dart-define`; local builds
fall back to the checked-in `pubspec.yaml` version (`1.0.0+1`).

Verify the active SDK against the committed pin at any time:

```sh
./tool/verify_flutter_pin.sh
```

Upgrading the SDK means changing `.fvmrc` and the `environment.sdk` constraint in `pubspec.yaml`
together; the verification script fails if they drift apart.

## Checks

```sh
fvm flutter analyze --fatal-infos
fvm flutter test
```

## Encrypted startup

The app creates its database key in platform secure storage and opens the
sqlite3mc-backed Drift file only after applying device-only backup protections.
If storage cannot be verified, startup shows a generic fatal-storage screen
instead of opening or replacing data.

## Layout

The version-1 Drift schema and encrypted executor live in `lib/data/database`.
Key and directory platform services live in `lib/data/services`; the ordered
composition root lives in `lib/app`. Regenerate the schema with
`fvm dart run build_runner build` and `fvm dart run drift_dev make-migrations`;
do not hand-edit generated Drift files. The rest of the target tree in
[architecture.md](docs/vulcan/architecture.md) is:

- `lib/app` — composition root, bootstrap, `go_router`
- `lib/core` — `Result` / `Failure` and clock only (no widgets, theme, or DI junk drawer)
- `lib/data` — Drift database, repositories, platform services
- `lib/domain` — models, repository contracts, thin use-cases
- `lib/ui/<feature>` — screens, Cubits, and owned Material 3 widgets (`ui/core` for shared primitives)

Construct dependencies at the composition root and provide them with
`RepositoryProvider` / `BlocProvider`. Do not add a service locator.
