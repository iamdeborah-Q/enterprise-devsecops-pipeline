
# ---- Dependencies stage ----
    FROM node:22-alpine AS build

    WORKDIR /app

    COPY package.json package-lock.json ./

    RUN npm ci --omit=dev && npm cache clean --force

    # ---- Production stage ----
    FROM node:22-alpine AS production

    ENV NODE_ENV=production

    # Install dumb-init for proper signal handling
    RUN apk add --no-cache dumb-init

    # Create non-root application user
    RUN addgroup -S appgroup && adduser -S appuser -G appgroup

    WORKDIR /app

    # Copy production dependencies
    COPY --from=build --chown=appuser:appgroup /app/node_modules ./node_modules

    # Copy application source
    COPY --chown=appuser:appgroup src/ ./src/

    USER appuser

    EXPOSE 5000

    ENTRYPOINT ["dumb-init", "--"]

    CMD ["node", "src/index.js"]
