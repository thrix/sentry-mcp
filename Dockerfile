# Build stage
FROM node:22-alpine AS build

WORKDIR /app

COPY package.json pnpm-workspace.yaml pnpm-lock.yaml turbo.json ./

# Read pnpm version from package.json packageManager field
RUN corepack enable && corepack install

COPY packages/mcp-core/package.json packages/mcp-core/
COPY packages/mcp-server/package.json packages/mcp-server/
COPY packages/mcp-server-mocks/package.json packages/mcp-server-mocks/
COPY packages/mcp-server-tsconfig/ packages/mcp-server-tsconfig/

RUN pnpm install --frozen-lockfile

COPY packages/mcp-core/ packages/mcp-core/
COPY packages/mcp-server/ packages/mcp-server/
COPY packages/mcp-server-mocks/ packages/mcp-server-mocks/

RUN pnpm run build --filter=@sentry/mcp-server

# Resolve pnpm catalog: versions into a portable package.json for npm
COPY scripts/resolve-prod-deps.cjs scripts/
RUN node scripts/resolve-prod-deps.cjs packages/mcp-server /tmp/package.json

# Runtime stage
FROM node:22-alpine

RUN addgroup -S mcp && adduser -S mcp -G mcp

WORKDIR /app

COPY --from=build /app/packages/mcp-server/dist/ ./dist/
COPY --from=build /tmp/package.json ./

RUN npm install --omit=dev --ignore-scripts && npm cache clean --force \
    && chown -R mcp:mcp /app

ENV NODE_ENV=production

USER mcp

ENTRYPOINT ["node", "dist/index.js"]
