FROM n8nio/n8n:latest

# ---------- run installs as root ----------
USER root

# Keep original working dir & entrypoint
WORKDIR /home/node/packages/cli
ENTRYPOINT []

# ---------- Playwright/browser config ----------
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_HEADLESS=1
ENV NODE_PATH=/usr/local/lib/node_modules
ENV NPM_CONFIG_FUND=false
ENV NPM_CONFIG_AUDIT=false

# Pin Playwright so browser build versions match at runtime
ARG PLAYWRIGHT_VERSION=1.48.0

# ---------- Alpine system libs for Playwright/Chromium ----------
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    nss \
    freetype \
    harfbuzz \
    libstdc++ \
    libgcc \
    libxkbcommon \
    mesa \
    eudev-libs \
    libxcomposite \
    libxrandr \
    libxi \
    libxrender \
    libxtst \
    libxshmfence \
    ttf-freefont \
    font-noto \
    font-noto-cjk \
    font-noto-emoji

# ---------- Playwright + Chromium (pinned) ----------
# Clean any old cache so we don’t keep stale browser folders
RUN rm -rf /ms-playwright \
 && npm install -g playwright@1.53.0 \
 && npx playwright@1.53.0 install chromium
 
# ---------- Stealth & helpers (real packages only) ----------
RUN npm install -g \
      playwright-extra \
      puppeteer-extra-plugin-stealth \
      fingerprint-injector \
      fingerprint-generator \
      user-agents \
 && npm cache clean --force

# ---------- (Optional) community Playwright nodes in n8n UI ----------
ENV N8N_COMMUNITY_PACKAGES="n8n-nodes-playwright,@couleetech/n8n-nodes-playwright-api"
RUN npm install -g --ignore-scripts n8n-nodes-playwright @couleetech/n8n-nodes-playwright-api

# Keep your entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Back to node user for running n8n
USER node

# Heroku calls this; your script should start n8n and respect $PORT
CMD ["/entrypoint.sh"]
