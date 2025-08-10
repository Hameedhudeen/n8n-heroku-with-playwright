FROM n8nio/n8n:latest

# ---------- run installs as root ----------
USER root

# Keep your original working dir and entrypoint behavior
WORKDIR /home/node/packages/cli
ENTRYPOINT []

# ---------- Playwright/browser config ----------
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_HEADLESS=1
# Let n8n Code nodes resolve global modules
ENV NODE_PATH=/usr/local/lib/node_modules

# ---------- Alpine system libs for Playwright headless Chromium ----------
# (Equivalent to --with-deps on Debian/Ubuntu)
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
    mesa-libgbm \
    udev \
    ttf-freefont \
    font-noto \
    font-noto-cjk \
    font-noto-emoji

# ---------- Playwright + Chromium ----------
# NOTE: no --with-deps on Alpine; we already added deps above via apk
RUN npm install -g playwright \
 &&
