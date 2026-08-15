#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/tool/api_verify"
if [[ ! -f .dart_tool/package_config.json ]]; then
  dart pub get
fi
exec dart run bin/verify_self_invite.dart "$@"
