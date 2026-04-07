#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/lib/xcode.sh"

echo "just: $(command -v just)"
echo "active developer directory: $(active_developer_dir)"

require_full_xcode

xcodebuild -version
TEST_DESTINATION_VALUE="$(resolve_test_destination)"
echo "resolved test destination: $TEST_DESTINATION_VALUE"
