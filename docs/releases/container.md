# Container Image

The Sentry MCP server can be run as a container using Docker or Podman.

## Pre-built Image

A pre-built image is published to GitHub Container Registry on every push to `main` and on version tags:

```
ghcr.io/getsentry/sentry-mcp:latest
ghcr.io/getsentry/sentry-mcp:0.30.0
```

PR images are also available for testing as `ghcr.io/getsentry/sentry-mcp:pr-<number>`.

## Running the Container

The server uses stdio transport — pass your Sentry auth token via environment variable:

```bash
docker run --rm -i \
  -e SENTRY_ACCESS_TOKEN=your-token \
  ghcr.io/getsentry/sentry-mcp:latest
```

### Self-hosted Sentry

For self-hosted Sentry instances, set `SENTRY_HOST` or `SENTRY_URL`:

```bash
docker run --rm -i \
  -e SENTRY_ACCESS_TOKEN=your-token \
  -e SENTRY_HOST=sentry.example.com \
  ghcr.io/getsentry/sentry-mcp:latest
```

Or using `SENTRY_URL` for full URL control:

```bash
docker run --rm -i \
  -e SENTRY_ACCESS_TOKEN=your-token \
  -e SENTRY_URL=https://sentry.example.com \
  ghcr.io/getsentry/sentry-mcp:latest
```

### AI-powered Search Tools

To enable AI-powered tools (`search_events`, `search_issues`, `search_issue_events`, `use_sentry`), provide an LLM API key:

```bash
docker run --rm -i \
  -e SENTRY_ACCESS_TOKEN=your-token \
  -e OPENAI_API_KEY=your-key \
  -e EMBEDDED_AGENT_PROVIDER=openai \
  ghcr.io/getsentry/sentry-mcp:latest
```

## Authentication

The `SENTRY_ACCESS_TOKEN` requires a Sentry User Auth Token with the following scopes:

- `org:read`
- `project:read`
- `issue:read`
- `issue:write`

Create a token at **Settings > Account > API > Auth Tokens** in your Sentry instance.

## Environment Variables

All configuration can be done via environment variables (CLI flags take precedence if both are set).

| Variable | Description |
|---|---|
| `SENTRY_ACCESS_TOKEN` | **Required.** Sentry User Auth Token (see scopes above) |
| `SENTRY_HOST` | Sentry hostname for self-hosted instances (e.g. `sentry.example.com`) |
| `SENTRY_URL` | Full Sentry URL (e.g. `https://sentry.example.com`) — alternative to `SENTRY_HOST` |
| `OPENAI_API_KEY` | OpenAI API key for AI-powered search tools |
| `ANTHROPIC_API_KEY` | Anthropic API key for AI-powered search tools |
| `EMBEDDED_AGENT_PROVIDER` | LLM provider override: `openai` or `anthropic` |
| `OPENAI_MODEL` | Override OpenAI model (default: `gpt-5`) |
| `ANTHROPIC_MODEL` | Override Anthropic model (default: `claude-sonnet-4-5`) |
| `MCP_SKILLS` | Comma-separated list of skills to enable (default: all) |
| `MCP_DISABLE_SKILLS` | Comma-separated list of skills to disable (e.g. `seer`) |
| `MCP_URL` | Override MCP server URL for tool metadata |
| `SENTRY_DSN` | Override DSN used for telemetry reporting |

Available skills: `inspect`, `seer`, `docs`, `triage`, `project-management`

## CLI Flags

Additional flags can be appended after the image name:

```bash
docker run --rm -i \
  -e SENTRY_ACCESS_TOKEN=your-token \
  ghcr.io/getsentry/sentry-mcp:latest \
  --agent --organization-slug=my-org
```

| Flag | Description |
|---|---|
| `--agent` | Agent mode: only expose `use_sentry` tool |
| `--experimental` | Enable experimental tools |
| `--organization-slug <slug>` | Constrain all calls to a specific organization |
| `--project-slug <slug>` | Constrain calls to a specific project |

## MCP Client Configuration

### Claude Desktop

```json
{
  "mcpServers": {
    "sentry": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-e", "SENTRY_ACCESS_TOKEN",
        "ghcr.io/getsentry/sentry-mcp:latest"
      ],
      "env": {
        "SENTRY_ACCESS_TOKEN": "your-token"
      }
    }
  }
}
```

For a self-hosted instance:

```json
{
  "mcpServers": {
    "sentry": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "-e", "SENTRY_ACCESS_TOKEN",
        "-e", "SENTRY_HOST",
        "ghcr.io/getsentry/sentry-mcp:latest"
      ],
      "env": {
        "SENTRY_ACCESS_TOKEN": "your-token",
        "SENTRY_HOST": "sentry.example.com"
      }
    }
  }
}
```

### Podman

Replace `docker` with `podman` in the examples above.

## Building Locally

```bash
docker build -t sentry-mcp .
```

## Image Details

- **Base image**: `node:22-alpine`
- **Architecture**: Multi-arch (`linux/amd64`, `linux/arm64`)
- **Transport**: stdio only (the Cloudflare worker handles HTTP/SSE)
- **User**: Runs as non-root (`mcp`)
