#!/usr/bin/with-contenv bashio

# Persistent storage for t3 and claude across container rebuilds
mkdir -p /data/t3code /data/.claude

# Symlink Claude config directory so credentials persist
if [ ! -L /root/.claude ]; then
    rm -rf /root/.claude
    ln -s /data/.claude /root/.claude
fi

export T3CODE_HOME=/data/t3code

# Configure Anthropic API key if provided
if bashio::config.has_value 'anthropic_api_key'; then
    export ANTHROPIC_API_KEY
    ANTHROPIC_API_KEY=$(bashio::config 'anthropic_api_key')
    bashio::log.info "Anthropic API key configured"
fi

# Install CLAUDE.md into /config if not already present
if [ ! -f /config/CLAUDE.md ]; then
    bashio::log.info "Installing CLAUDE.md into HA config directory"
    cp /etc/t3code/CLAUDE.md /config/CLAUDE.md
fi

bashio::log.info "Starting T3 Code server on port 3773..."
bashio::log.info "Working directory: /config"
bashio::log.info "Check the logs below for the pairing token/URL"

cd /config
exec t3 serve --host 0.0.0.0 --port 3773
