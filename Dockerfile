# Playwright + browsers preinstalled (v1.54.2)
FROM mcr.microsoft.com/playwright:v1.54.2-jammy

# ---- base setup ----
USER root
WORKDIR /app

# Keep tzdata non-interactive on Debian/Ubuntu
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Make globally installed node modules resolvable by n8n Code node
ENV NODE_PATH=/usr/local/lib/node_modules:/usr/lib/node_modules

# Allow npm postinstall scripts when running as root (helps some packages)
ENV NPM_CONFIG_UNSAFE_PERM=true

# Playwright runtime env
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_HEADLESS=1

# Quiet npm
ENV NPM_CONFIG_FUND=false
ENV NPM_CONFIG_AUDIT=false

# Enable community package (node) install feature (default is true, set explicitly)
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Allow Code node to import modules (override in Heroku config vars if you want a tighter allowlist)
ENV NODE_FUNCTION_ALLOW_BUILTIN=*
ENV NODE_FUNCTION_ALLOW_EXTERNAL=*

# Minimal extras: init, certs, tzdata, fonts (helpful for screenshots/PDFs)
RUN apt-get update && apt-get install -y --no-install-recommends \
      dumb-init ca-certificates tzdata \
      fonts-noto fonts-noto-cjk fonts-noto-color-emoji \
  && rm -rf /var/lib/apt/lists/*

# ---- install n8n v2 + matching Playwright (keep versions in lockstep) ----
RUN npm i -g n8n@2.2.4 playwright@1.54.2 \
  && npm cache clean --force

# Safety check: ensure Node >= 20.19 for n8n v2
RUN node -v && node -e "const [M,m]=process.versions.node.split('.').map(Number); if (M<20 || (M===20 && m<19)) { console.error('Node too old for n8n v2 (need >=20.19)'); process.exit(1); }"

# ---- optional runtime package install (ephemeral on Heroku) ----
# Set N8N_EXTRA_PACKAGES to a space-separated list, e.g.:
#   N8N_EXTRA_PACKAGES="axios lodash date-fns"
# These will be installed on each container start.
RUN bash -lc 'cat > /bootstrap.sh <<"EOF"
#!/usr/bin/env bash
set -euo pipefail

if [ -n "${N8N_EXTRA_PACKAGES:-}" ]; then
  echo "[bootstrap] Installing extra npm packages (ephemeral): ${N8N_EXTRA_PACKAGES}"
  npm install -g --no-fund --no-audit --no-update-notifier ${N8N_EXTRA_PACKAGES}
fi

exec /entrypoint.sh "$@"
EOF
chmod +x /bootstrap.sh'

# ---- your startup script ----
# This script should export N8N_PORT=$PORT and N8N_HOST=0.0.0.0, then run `n8n start`
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Heroku-friendly init
ENTRYPOINT ["dumb-init", "--"]
CMD ["/bootstrap.sh"]
