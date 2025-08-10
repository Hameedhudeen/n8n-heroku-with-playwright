FROM n8nio/n8n:latest

# ---------- run installs as root ----------
USER root

# Keep your original working dir and entrypoint behavior
WORKDIR /home/node/packages/cli
ENTRYPOINT []

# ---------- Playwright/browser config ----------
# Cache browsers in a fixed path for better Docker layer caching
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
# Default headless (override in code if needed)
ENV PLAYWRIGHT_HEADLESS=1
# Ensure Node finds global modules installed with npm -g
ENV NODE_PATH=/usr/local/lib/node_modules

# ---------- Playwright + Chromium (with OS deps) ----------
# --with-deps installs required Linux libs in one go (CI/Heroku friendly)
RUN npm install -g playwright \
 && npx playwright install --with-deps chromium

# ---------- (Optional) also install Firefox/WebKit ----------
# RUN npx playwright install --with-deps firefox webkit

# ---------- Helpful fonts for screenshots/PDFs ----------
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-noto fonts-noto-color-emoji fonts-liberation \
 && rm -rf /var/lib/apt/lists/*

# ---------- Stealth & humanization helpers ----------
# playwright-extra enables plugins; stealth plugin comes from puppeteer-extra
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
