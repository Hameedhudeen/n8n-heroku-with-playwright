FROM n8nio/n8n:latest

# ---------- run installs as root ----------
USER root

# Keep your original working dir and entrypoint behavior
WORKDIR /home/node/packages/cli
ENTRYPOINT []

# ---------- Playwright/browser config ----------
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_HEADLESS=1
# Let n8n Code nodes resolve global modules installed with npm -g
ENV NODE_PATH=/usr/local/lib/node_modules

# ---------- Alpine system libs for Playwright/Chromium ----------
# (Alpine equivalents for what --with-deps would do on Debian/Ubuntu)
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

# ---------- Playwright + bundled Chromium ----------
# NOTE: do NOT use --with-deps on Alpine (it tries apt-get)
RUN npm install -g playwright \
 && npx playwright install chromium

# ---------- Stealth & humanization helpers ----------
RUN npm install -g playwright-extra puppeteer-extra-plugin-stealth @extra/humanize @extra/recaptcha \
 && npm cache clean --force

# ---------- (Optional) community Playwright nodes in n8n UI ----------
# ENV N8N_COMMUNITY_PACKAGES="n8n-nodes-playwright,@couleetech/n8n-nodes-playwright-api"
# RUN npm install -g n8n-nodes-playwright @couleetech/n8n-nodes-playwright-api

# Keep your entrypoint script
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Back to node user for running n8n
USER node

# Heroku calls this; your script should start n8n and respect $PORT
CMD ["/entrypoint.sh"]
