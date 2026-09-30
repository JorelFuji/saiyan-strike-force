#!/usr/bin/env bash
#
# Fails unless the active Flutter SDK is exactly the release pinned in .fvmrc
# and its Dart SDK matches the constraint in pubspec.yaml.
#
# Run before analyze/test/build, locally and in CI. Override the command used to
# probe the active SDK with FLUTTER_CMD (e.g. FLUTTER_CMD="fvm flutter").
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ -n "${FLUTTER_CMD:-}" ]]; then
  read -r -a flutter_cmd <<<"$FLUTTER_CMD"
elif command -v flutter >/dev/null 2>&1; then
  flutter_cmd=(flutter)
elif command -v fvm >/dev/null 2>&1; then
  flutter_cmd=(fvm flutter)
else
  echo "error: no Flutter SDK found on PATH and fvm is not installed" >&2
  exit 1
fi

expected_flutter="$(sed -n 's/.*"flutter"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' .fvmrc)"
if [[ -z "$expected_flutter" ]]; then
  echo "error: .fvmrc does not pin a Flutter release" >&2
  exit 1
fi

expected_dart="$(awk '
  /^environment:/ { in_env = 1; next }
  /^[^[:space:]#]/ { in_env = 0 }
  in_env && $1 == "sdk:" { gsub(/"/, "", $2); print $2; exit }
' pubspec.yaml)"
if [[ -z "$expected_dart" || "$expected_dart" == *"^"* || "$expected_dart" == *">"* ]]; then
  echo "error: pubspec.yaml must pin an exact Dart SDK version, found '${expected_dart:-none}'" >&2
  exit 1
fi

version_json="$("${flutter_cmd[@]}" --version --machine)"
actual_flutter="$(sed -n 's/.*"frameworkVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$version_json")"
actual_channel="$(sed -n 's/.*"channel"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$version_json")"
actual_dart="$(sed -n 's/.*"dartSdkVersion"[[:space:]]*:[[:space:]]*"\([^" ]*\).*/\1/p' <<<"$version_json")"

status=0
if [[ "$actual_flutter" != "$expected_flutter" ]]; then
  echo "error: active Flutter is $actual_flutter, .fvmrc pins $expected_flutter" >&2
  status=1
fi
if [[ "$actual_channel" != "stable" ]]; then
  echo "error: active Flutter channel is '$actual_channel', expected 'stable'" >&2
  status=1
fi
if [[ "$actual_dart" != "$expected_dart" ]]; then
  echo "error: active Dart is $actual_dart, pubspec.yaml pins $expected_dart" >&2
  status=1
fi

if [[ $status -ne 0 ]]; then
  echo "hint: run 'fvm install && fvm use $expected_flutter', then prefix commands with 'fvm'" >&2
  exit $status
fi

echo "Flutter $actual_flutter (stable) with Dart $actual_dart matches the committed pin."
