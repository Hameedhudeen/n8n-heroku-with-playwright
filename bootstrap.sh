#!/usr/bin/env bash
set -euo pipefail

if [ -n "${N8N_EXTRA_PACKAGES:-}" ]; then
  echo "[bootstrap] Installing extra npm packages (ephemeral): ${N8N_EXTRA_PACKAGES}"
  npm install -g --no-fund --no-audit --no-update-notifier ${N8N_EXTRA_PACKAGES}
fi

exec /entrypoint.sh "$@"
