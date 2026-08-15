#!/usr/bin/env bash
# Runs community backend checks without loading the Flutter app graph (avoids native_assets error).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/tool/api_verify"
if [[ ! -f .dart_tool/package_config.json ]]; then
  dart pub get
fi
exec dart run bin/verify_community_backend_fixes.dart "$@"
