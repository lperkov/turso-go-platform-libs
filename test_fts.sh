#!/usr/bin/env bash
set -euo pipefail

TURSO_GO_VERSION=${TURSO_GO_VERSION:-v0.8.0-pre.11}
TURSO_GO_TEST_TAGS=${TURSO_GO_TEST_TAGS:-}
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if command -v cygpath >/dev/null 2>&1; then
  ROOT=$(cygpath -m "$ROOT")
fi
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

cat >"$TEST_DIR/go.mod" <<EOF
module turso-platform-fts-test

go 1.24.0

require turso.tech/database/tursogo $TURSO_GO_VERSION

replace github.com/tursodatabase/turso-go-platform-libs => $ROOT
EOF

cd "$TEST_DIR"
go mod download all

GO_TEST_ARGS=(-count=1 -run '^TestFTS$')
if [[ -n "$TURSO_GO_TEST_TAGS" ]]; then
  GO_TEST_ARGS+=(--tags "$TURSO_GO_TEST_TAGS")
fi

go test "${GO_TEST_ARGS[@]}" turso.tech/database/tursogo
