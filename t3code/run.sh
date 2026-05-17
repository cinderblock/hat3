#!/usr/bin/with-contenv bashio

# Persistent storage for t3 and claude across container rebuilds
mkdir -p /data/t3code /data/.claude

# Symlink Claude config directory so credentials persist
if [ ! -L /root/.claude ]; then
    rm -rf /root/.claude
    ln -s /data/.claude /root/.claude
fi

# Persist .claude.json (settings/state file) across container rebuilds
if [ -f /data/.claude.json ]; then
    ln -sf /data/.claude.json /root/.claude.json
elif [ -f /root/.claude.json ]; then
    mv /root/.claude.json /data/.claude.json
    ln -sf /data/.claude.json /root/.claude.json
else
    touch /data/.claude.json
    ln -sf /data/.claude.json /root/.claude.json
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

# Verify Claude Code works in agent-SDK mode (catches version/protocol issues)
bashio::log.info "Testing Claude Code agent compatibility..."
test_exit=0
CLAUDE_CODE_ENTRYPOINT=sdk-ts CLAUDE_AGENT_SDK_VERSION=0.2.141 \
  timeout 5 claude \
    --output-format stream-json \
    --input-format stream-json \
    --verbose \
    --permission-mode bypassPermissions \
    --allow-dangerously-skip-permissions \
    --permission-prompt-tool stdio \
  </dev/null >/tmp/claude-test.out 2>/tmp/claude-test.err || test_exit=$?
if [ $test_exit -eq 0 ] || [ $test_exit -eq 124 ]; then
    bashio::log.info "Claude agent mode OK (exit $test_exit, version: $(claude --version 2>/dev/null))"
else
    bashio::log.warning "Claude agent test FAILED (exit $test_exit):"
    head -5 /tmp/claude-test.out | while IFS= read -r line; do bashio::log.warning "  stdout: $line"; done
    head -5 /tmp/claude-test.err | while IFS= read -r line; do bashio::log.warning "  stderr: $line"; done
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
