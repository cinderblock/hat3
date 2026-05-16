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

# Install t3 globally
RUN npm install -g t3

# Claude Code installs to ~/.local/bin
ENV PATH="/root/.local/bin:${PATH}"

# Install Claude Code native binary (not the npm JS wrapper — the agent SDK
# needs the native binary for stream-JSON protocol support)
RUN curl -fsSL https://claude.ai/install.sh | bash && claude --version

# Copy rootfs overlay (helper scripts, CLAUDE.md template)
COPY rootfs /

COPY run.sh /
RUN chmod a+x /run.sh /usr/local/bin/ha

CMD ["/run.sh"]
