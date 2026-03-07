#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"

echo "==> Benchmarking zsh interactive startup..."

# Run hyperfine and capture JSON output
HYPERFINE_OUTPUT=$(mktemp)
hyperfine \
    --warmup 3 \
    --runs 10 \
    --export-json "${HYPERFINE_OUTPUT}" \
    'zsh -i -c exit'

# Extract mean time and stddev from hyperfine JSON
MEAN=$(python3 -c "
import json, sys
data = json.load(open('${HYPERFINE_OUTPUT}'))
print(data['results'][0]['mean'])
")
STDDEV=$(python3 -c "
import json, sys
data = json.load(open('${HYPERFINE_OUTPUT}'))
print(data['results'][0]['stddev'])
")

# Format for benchmark-action (customSmallerIsBetter)
cat > "${ROOT_DIR}/benchmark-results.json" << EOF
[
  {
    "name": "zsh interactive startup",
    "unit": "seconds",
    "value": ${MEAN},
    "range": "${STDDEV}",
    "extra": "hyperfine --warmup 3 --runs 10"
  }
]
EOF

echo "==> Benchmark results:"
echo "    Mean: ${MEAN}s"
echo "    Stddev: ${STDDEV}s"
echo "==> Results written to benchmark-results.json"

rm -f "${HYPERFINE_OUTPUT}"
