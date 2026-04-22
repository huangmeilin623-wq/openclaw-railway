#!/bin/sh
set -e

# Fix volume permissions
mkdir -p /home/node/.openclaw/cron
chown -R node:node /home/node/.openclaw

# Bootstrap config from env var (always, if env var is set)
if [ -n "$OPENCLAW_BOOTSTRAP_CONFIG_B64" ]; then
  echo "$OPENCLAW_BOOTSTRAP_CONFIG_B64" | base64 -d > /home/node/.openclaw/openclaw.json
  chown node:node /home/node/.openclaw/openclaw.json
  echo "[entrypoint] bootstrapped openclaw.json from env var"
fi

# Bootstrap cron jobs from env var (always overwrite so updates take effect)
if [ -n "$OPENCLAW_BOOTSTRAP_CRON_B64" ]; then
  echo "$OPENCLAW_BOOTSTRAP_CRON_B64" | base64 -d > /home/node/.openclaw/cron/jobs.json
  chown node:node /home/node/.openclaw/cron/jobs.json
  echo "[entrypoint] bootstrapped cron/jobs.json from env var"
fi

# Install wechat-mp plugin
cd /app
node openclaw.mjs plugins install "@openclaw-china/wechat-mp" || true

exec su -s /bin/sh node -c 'cd /app && exec node openclaw.mjs gateway --allow-unconfigured'
