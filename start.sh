#!/bin/bash
set -e

mkdir -p /data/.nanobot/workspace
mkdir -p /data/.nanobot/sessions
mkdir -p /data/.nanobot/cron
mkdir -p /data/.codex

# Default to official OpenAI endpoint unless explicitly overridden.
if [ -z "${OPENAI_BASE_URL:-}" ]; then
  export OPENAI_BASE_URL="https://api.openai.com/v1"
fi

# Let Claude Code use Kimi as an Anthropic-compatible backend when available.
if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -n "${KIMI_API_KEY:-}" ]; then
  export ANTHROPIC_API_KEY="$KIMI_API_KEY"
fi
if [ -z "${ANTHROPIC_BASE_URL:-}" ] && [ -n "${ANTHROPIC_API_KEY:-}" ] && [ -n "${KIMI_API_KEY:-}" ]; then
  export ANTHROPIC_BASE_URL="https://api.kimi.com/coding/"
fi

# If OpenAI base URL is explicitly set to Kimi and OpenAI key is missing,
# reuse Kimi key for OpenAI-compatible auth.
if [ -z "${OPENAI_API_KEY:-}" ] && [ -n "${KIMI_API_KEY:-}" ] && [[ "${OPENAI_BASE_URL:-}" == *"api.kimi.com"* ]]; then
  export OPENAI_API_KEY="$KIMI_API_KEY"
fi

# Skip Claude Code onboarding prompt.
if [ ! -f /data/.claude.json ]; then
  printf '{\n  "hasCompletedOnboarding": true\n}\n' > /data/.claude.json
fi

# Force Codex API-key auth mode to avoid browser login prompts.
if [ ! -f /data/.codex/config.toml ]; then
  cat > /data/.codex/config.toml <<'EOF'
forced_login_method = "api"
preferred_auth_method = "apikey"
EOF
fi

exec python /app/server.py
