# Debian/Ubuntu base with Playwright + Chromium/Firefox/WebKit preinstalled
# Pick a tag that matches the Playwright version you want
FROM mcr.microsoft.com/playwright:v1.53.0-jammy

# ---- run installs as root ----
USER root
WORKDIR /app

# Make global node modules visible in n8n Code nodes
ENV NODE_PATH=/usr/local/lib/node_modules
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_HEADLESS=1
ENV NPM_CONFIG_FUND=false
ENV NPM_CONFIG_AUDIT=false

# n8n needs git (for community packages) and tzdata (optional)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git tzdata dumb-init \
 && rm -rf /var/lib/apt/lists/*

# Install n8n from npm (Debian base; no musl issues)
# Pin if you want a specific n8n version, e.g. n8n@1.105.4
RUN npm install -g n8n

# Optional: stealth & helpers (only real packages; nothing deprecated/renamed)
RUN npm install -g \
      playwright-extra \
      puppeteer-extra-plugin-stealth \
      fingerprint-injector \
      fingerprint-generator \
      user-agents \
  && npm cache clean --force

# Optional: community Playwright nodes (skip postinstall that enforces pnpm)
ENV N8N_COMMUNITY_PACKAGES="n8n-nodes-playwright,@couleetech/n8n-nodes-playwright-api"
RUN npm install -g --ignore-scripts n8n-nodes-playwright @couleetech/n8n-nodes-playwright-api || true

# Keep your existing entrypoint script from the repo
# (it should export PORT and start n8n)
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Drop privileges to a non-root user for runtime
# The Playwright base image ships with user "pwuser"
# We can reuse it or create "node". We'll use pwuser.
USER pwuser

# Heroku will set $PORT; your script should honor it and run `n8n start`
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/entrypoint.sh"]
