# ✅ Use Microsoft’s Playwright image (Ubuntu Jammy + all browser deps preinstalled)
FROM mcr.microsoft.com/playwright:v1.53.0-jammy

# ---- base env (avoid tzdata prompts, make globals resolvable in Code node) ----
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    NODE_PATH=/usr/local/lib/node_modules \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    PLAYWRIGHT_HEADLESS=1 \
    NPM_CONFIG_FUND=false \
    NPM_CONFIG_AUDIT=false

# ---- minimal OS utils + fonts (nice screenshots) ----
RUN apt-get update && apt-get install -y --no-install-recommends \
      dumb-init ca-certificates \
      fonts-noto fonts-noto-cjk fonts-noto-color-emoji \
  && rm -rf /var/lib/apt/lists/*

# ---- n8n + Playwright + helpers (global) ----
# n8n pinned to your working version; Playwright pinned to match base image
RUN npm install -g \
      n8n@1.105.4 \
      playwright@1.53.0 \
      playwright-extra \
      puppeteer-extra-plugin-stealth \
      fingerprint-injector \
      fingerprint-generator \
      user-agents \
  && npm cache clean --force

# ---- app layout ----
WORKDIR /app
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown 1001:0 /entrypoint.sh

# The Playwright image runs as user `pwuser` (uid 1001) by default — perfect for Heroku
USER 1001

# Heroku will send SIGTERM; dumb-init handles it cleanly
ENTRYPOINT ["/usr/bin/dumb-init","--"]
CMD ["/entrypoint.sh"]
