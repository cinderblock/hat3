ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install Node.js (>=22 from Alpine 3.21), build tools for node-pty, and utils
RUN apk add --no-cache \
    nodejs \
    npm \
    build-base \
    python3 \
    git \
    curl \
    bash \
    jq \
    openssh-client

# node-pty requires node-gyp to build from source (no linux musl prebuild)
RUN npm install -g node-gyp

# Install t3 globally (includes claude-agent-sdk with platform-specific binary)
RUN npm install -g t3

# The SDK's optional dep @anthropic-ai/claude-agent-sdk-linux-x64-musl
# contains a native Claude binary version-matched to the SDK.
# Symlink it to PATH so both T3 (which passes "claude" to the SDK) and
# our auth-check commands find the correct binary.
ENV PATH="/root/.local/bin:${PATH}"
RUN SDK_CLAUDE="$(find /usr/local/lib/node_modules/t3/node_modules/@anthropic-ai \
        -name 'claude' -type f -path '*musl*' 2>/dev/null | head -1)" && \
    if [ -n "$SDK_CLAUDE" ]; then \
        chmod +x "$SDK_CLAUDE" && \
        mkdir -p /usr/local/bin && \
        ln -sf "$SDK_CLAUDE" /usr/local/bin/claude && \
        echo "Using SDK-bundled Claude binary: $SDK_CLAUDE"; \
    else \
        echo "SDK musl binary not found — installing via curl" && \
        curl -fsSL https://claude.ai/install.sh | bash; \
    fi && \
    claude --version

# Copy rootfs overlay (helper scripts, CLAUDE.md template)
COPY rootfs /

COPY run.sh /
RUN chmod a+x /run.sh /usr/local/bin/ha

CMD ["/run.sh"]
