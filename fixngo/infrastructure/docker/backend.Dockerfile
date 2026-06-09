# ── Build stage ───────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app
COPY fixngo/backend/package*.json ./
RUN npm ci --omit=dev

# ── Production stage ─────────────────────────────────────────────────────────
FROM node:20-alpine AS production
RUN apk add --no-cache dumb-init

# Non-root user for security
RUN addgroup -g 1001 -S nodejs && adduser -S fixngo -u 1001
WORKDIR /app

COPY --from=builder --chown=fixngo:nodejs /app/node_modules ./node_modules
COPY --chown=fixngo:nodejs fixngo/backend/src ./src
COPY --chown=fixngo:nodejs fixngo/backend/package.json ./

USER fixngo
EXPOSE 5000

# dumb-init handles PID 1 and signal forwarding
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "src/server.js"]
