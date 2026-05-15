#!/usr/bin/with-contenv bashio

# Persistent storage for t3 and claude across container rebuilds
mkdir -p /data/t3code /data/.claude

# Symlink Claude config directory so credentials persist
if [ ! -L /root/.claude ]; then
    rm -rf /root/.claude
    ln -s /data/.claude /root/.claude
fi

export T3CODE_HOME=/data/t3code

# Override the Docker hostname (HA sets it to the full slug with repo hash)
hostname t3code 2>/dev/null || true

# Check Claude auth status and guide user if not logged in
if claude auth status 2>/dev/null | grep -q '"loggedIn"[[:space:]]*:[[:space:]]*true'; then
    bashio::log.info "Claude is authenticated"
else
    bashio::log.warning "=========================================="
    bashio::log.warning "  Claude is NOT authenticated."
    bashio::log.warning "  To log in, open a shell to this add-on:"
    bashio::log.warning ""
    bashio::log.warning "    ha addons exec local_t3code -- claude /quit"
    bashio::log.warning ""
    bashio::log.warning "  Or via Docker:"
    bashio::log.warning ""
    bashio::log.warning "    docker exec -it addon_local_t3code claude /quit"
    bashio::log.warning ""
    bashio::log.warning "  Follow the OAuth prompts, then restart"
    bashio::log.warning "  this add-on."
    bashio::log.warning "=========================================="
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
