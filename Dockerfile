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

# Playwright runtime env
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_HEADLESS=1

# Quiet npm
ENV NPM_CONFIG_FUND=false
ENV NPM_CONFIG_AUDIT=false

# Minimal extras: init, certs, tzdata, fonts (helpful for screenshots/PDFs)
RUN apt-get update && apt-get install -y --no-install-recommends \
      dumb-init ca-certificates tzdata \
      fonts-noto fonts-noto-cjk fonts-noto-color-emoji \
  && rm -rf /var/lib/apt/lists/*

# ---- install n8n + matching Playwright (keep versions in lockstep) ----
RUN npm i -g n8n@2.2.4 playwright@1.54.2 \
  && npm cache clean --force

# ---- your startup script ----
# This script should export N8N_PORT=$PORT and N8N_HOST=0.0.0.0, then run `n8n start`
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Heroku-friendly init
ENTRYPOINT ["dumb-init", "--"]
CMD ["/entrypoint.sh"]
