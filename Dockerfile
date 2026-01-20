# Multi-stage build for optimized production image
FROM node:18-slim AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app

# Copy package files (package-lock.json is needed for faster builds)
COPY package.json package-lock.json* ./
# Use npm ci with optimizations for faster, reproducible builds
RUN if [ -f package-lock.json ]; then \
      npm ci --prefer-offline --no-audit --loglevel=error --no-fund; \
    else \
      npm install --prefer-offline --no-audit --loglevel=error --no-fund; \
    fi

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
# Copy source code (node_modules excluded via .dockerignore)
COPY . .

# Build the Next.js application
# Ensure public directory exists (create empty if it doesn't exist)
RUN mkdir -p public
RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
