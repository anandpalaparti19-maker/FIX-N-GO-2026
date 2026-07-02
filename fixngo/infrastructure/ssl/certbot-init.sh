#!/bin/bash
# ═══════════════════════════════════════════════════════
# Fix-N-Go — SSL Certificate Setup (Let's Encrypt)
# Run this once to obtain initial certificates.
# Certbot sidecar in docker-compose handles renewals.
# ═══════════════════════════════════════════════════════

set -e

DOMAIN="${1:-api.fixngo.in}"
EMAIL="${2:-admin@fixngo.in}"
SSL_DIR="$(dirname "$0")"

echo "╔═══════════════════════════════════════════════╗"
echo "║  Fix-N-Go SSL Certificate Setup               ║"
echo "║  Domain: ${DOMAIN}                             ║"
echo "╚═══════════════════════════════════════════════╝"

# Create directories
mkdir -p "${SSL_DIR}/certs"
mkdir -p "${SSL_DIR}/webroot"

# Generate DH parameters for forward secrecy (if not exists)
if [ ! -f "${SSL_DIR}/dhparam.pem" ]; then
  echo "Generating DH parameters (this takes a few minutes)..."
  openssl dhparam -out "${SSL_DIR}/dhparam.pem" 2048
  echo "✅ DH parameters generated"
fi

# Obtain certificate via Certbot standalone mode
echo "Requesting certificate from Let's Encrypt..."
docker run --rm \
  -p 80:80 \
  -v "${SSL_DIR}/certs:/etc/letsencrypt" \
  -v "${SSL_DIR}/webroot:/var/www/certbot" \
  certbot/certbot:latest certonly \
    --standalone \
    --non-interactive \
    --agree-tos \
    --email "${EMAIL}" \
    -d "${DOMAIN}"

echo ""
echo "✅ SSL certificate obtained successfully!"
echo ""
echo "Certificate files:"
echo "  Full chain: ${SSL_DIR}/certs/live/${DOMAIN}/fullchain.pem"
echo "  Private key: ${SSL_DIR}/certs/live/${DOMAIN}/privkey.pem"
echo ""
echo "Next steps:"
echo "  1. Update nginx.conf ssl_certificate paths if domain differs"
echo "  2. Start services: cd infrastructure && docker-compose up -d"
echo "  3. Certbot sidecar will auto-renew every 12 hours"
