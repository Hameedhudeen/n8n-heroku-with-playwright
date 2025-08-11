FROM mcr.microsoft.com/playwright:v1.53.0-jammy

USER root
WORKDIR /app

# make global node modules visible to n8n Code nodes
ENV NODE_PATH=/usr/local/lib/node_modules
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_HEADLESS=1
ENV NPM_CONFIG_FUND=false
ENV NPM_CONFIG_AUDIT=false
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# non-interactive tzdata + runtime tools
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      git tzdata dumb-init \
 && rm -rf /var/lib/apt/lists/* \
 && unset DEBIAN_FRONTEND

# install n8n
RUN npm install -g n8n

# optional extras
RUN npm install -g \
      playwright-extra \
      puppeteer-extra-plugin-stealth \
      fingerprint-injector \
      fingerprint-generator \
      user-agents \
 && npm cache clean --force

# optional community nodes (ignore pnpm-only postinstall)
ENV N8N_COMMUNITY_PACKAGES="n8n-nodes-playwright,@couleetech/n8n-nodes-playwright-api"
RUN npm install -g --ignore-scripts n8n-nodes-playwright @couleetech/n8n-nodes-playwright-api || true

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# drop privileges; pwuser exists in the Playwright base image
USER pwuser

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/entrypoint.sh"]
