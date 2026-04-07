#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/xcode.sh"

require_full_xcode

TEST_DESTINATION_VALUE="$(resolve_test_destination)"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$TEST_DESTINATION_VALUE" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  test
