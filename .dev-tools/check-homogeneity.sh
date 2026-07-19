#!/usr/bin/env bash
# Compatibility entry point; implementation lives in scripts/.
set -euo pipefail

REPOSITORY_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
exec bash "${REPOSITORY_ROOT}/scripts/check-homogeneity.sh" "$@"
