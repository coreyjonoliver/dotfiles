#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"

echo "==> Linting shell scripts..."

errors=0

# Find all .sh files (excluding .tmpl which may contain chezmoi template syntax)
while IFS= read -r -d '' file; do
    echo "  Checking ${file#"${ROOT_DIR}"/}..."
    if ! shellcheck "$file"; then
        errors=$((errors + 1))
    fi
done < <(find "${ROOT_DIR}" -type f -name "*.sh" -not -path "*/.git/*" -print0)

if [[ ${errors} -gt 0 ]]; then
    echo "==> Found issues in ${errors} file(s)"
    exit 1
fi

echo "==> All shell scripts passed"
