#!/usr/bin/env bash
# Run on the Aliyun server, inside a clone of the repo:
#   git clone https://github.com/LenaYan/qwerty-learner.git ~/qwerty-learner
#   cd ~/qwerty-learner && bash scripts/deploy/deploy.sh [--setup-nginx <domain_or_ip>]
# Each run: git pull -> yarn install -> yarn build -> atomically publish to $WEBROOT/current.
# --setup-nginx writes /etc/nginx/conf.d/qwerty-learner.conf (needs root); only needed once.
# Env overrides: BRANCH (default master), WEBROOT (default /var/www/qwerty-learner).
set -euo pipefail

BRANCH="${BRANCH:-master}"
WEBROOT="${WEBROOT:-/var/www/qwerty-learner}"
REGISTRY=https://registry.npmmirror.com
cd "$(git rev-parse --show-toplevel)"

for c in git node; do command -v "$c" >/dev/null || { echo "$c is required (Node 18+)"; exit 1; }; done
command -v yarn >/dev/null || npm install -g yarn --registry="$REGISTRY"

if [ "${1:-}" = "--setup-nginx" ]; then
  command -v nginx >/dev/null || { echo "nginx is required"; exit 1; }
  mkdir -p "$WEBROOT"
  cat > /etc/nginx/conf.d/qwerty-learner.conf <<EOF
server {
    listen 80;
    server_name ${2:-_};
    root ${WEBROOT}/current;
    index index.html;

    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;

    location /assets/ { expires 1y; add_header Cache-Control "public, immutable"; }
    location = /index.html { add_header Cache-Control "no-cache"; }

    # SPA routes (/repeater, /analysis, ...) fall back to index.html
    location / { try_files \$uri \$uri/ /index.html; }
}
EOF
  nginx -t && (systemctl reload nginx 2>/dev/null || systemctl start nginx)
fi

echo "==> Pulling $BRANCH"
git fetch origin "$BRANCH"
git checkout "$BRANCH"
git merge --ff-only "origin/$BRANCH"

echo "==> Installing dependencies"
yarn install --frozen-lockfile --registry="$REGISTRY"

echo "==> Building"
yarn build

REL="$WEBROOT/releases/$(date +%Y%m%d%H%M%S)"
mkdir -p "$REL"
cp -a build/. "$REL/"
ln -sfn "$REL" "$WEBROOT/current.tmp"
mv -Tf "$WEBROOT/current.tmp" "$WEBROOT/current"

# keep the 3 newest releases for rollback
ls -1dt "$WEBROOT"/releases/* | tail -n +4 | xargs -r rm -rf
echo "==> Deployed $(git rev-parse --short HEAD)"
