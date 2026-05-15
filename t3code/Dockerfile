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

# Install t3 and Claude Code globally
RUN npm install -g t3 @anthropic-ai/claude-code

# Copy rootfs overlay (helper scripts, CLAUDE.md template)
COPY rootfs /

COPY run.sh /
RUN chmod a+x /run.sh /usr/local/bin/ha

CMD ["/run.sh"]
