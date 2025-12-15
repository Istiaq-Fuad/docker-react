# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile

COPY . .
ENV NODE_ENV=production
RUN pnpm build

# Production stage
FROM node:20-alpine

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=80

# Create non-root user
RUN addgroup -g 1001 nodejs \
 && adduser -S -u 1001 nextjs -G nodejs

# Copy standalone output
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

USER nextjs

EXPOSE 80

CMD ["node", "server.js"]
