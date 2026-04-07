#!/usr/bin/env bash

ROOT_DIR="${ROOT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
PROJECT="${PROJECT:-$ROOT_DIR/Jisa.xcodeproj}"
SCHEME="${SCHEME:-Jisa}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/.build/DerivedData}"
DEFAULT_XCODE_DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

active_developer_dir() {
  if [[ -n "${DEVELOPER_DIR:-}" ]]; then
    printf '%s\n' "$DEVELOPER_DIR"
    return
  fi

  xcode-select -p 2>/dev/null || true
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "error: missing required command: $command_name" >&2
    exit 1
  fi
}

require_full_xcode() {
  require_command xcode-select
  require_command xcodebuild

  if ! xcodebuild -version >/dev/null 2>&1 && [[ -z "${DEVELOPER_DIR:-}" ]] && [[ -d "$DEFAULT_XCODE_DEVELOPER_DIR" ]]; then
    export DEVELOPER_DIR="$DEFAULT_XCODE_DEVELOPER_DIR"
  fi

  if ! xcodebuild -version >/dev/null 2>&1; then
    cat >&2 <<EOF
error: xcodebuild is unavailable because the active developer directory is not a full Xcode installation.
active developer directory: $(active_developer_dir)
try: export DEVELOPER_DIR=$DEFAULT_XCODE_DEVELOPER_DIR
fix: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
EOF
    exit 1
  fi
}

show_destinations() {
  xcodebuild -project "$PROJECT" -scheme "$SCHEME" -showdestinations
}

resolve_test_destination() {
  local simulator_id

  if [[ -n "${TEST_DESTINATION:-}" ]]; then
    printf '%s\n' "$TEST_DESTINATION"
    return
  fi

  simulator_id="$(
    show_destinations 2>/dev/null \
      | sed -nE 's/.*platform:iOS Simulator.*id:([A-F0-9-]{36}).*name:iPhone[^,}]*.*/\1/p' \
      | head -n 1 \
      || true
  )"

  if [[ -n "$simulator_id" ]]; then
    printf 'id=%s\n' "$simulator_id"
    return
  fi

  cat >&2 <<EOF
error: failed to resolve a default iPhone simulator destination for scheme '$SCHEME'
hint: install an iOS Simulator runtime in Xcode, or rerun with TEST_DESTINATION='<xcodebuild destination>'
available destinations:
EOF
  show_destinations >&2 || true
  exit 1
}
