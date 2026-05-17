# T3 Code Home Assistant Add-on

## Goal

Create a Home Assistant add-on that runs the `t3` npm package in headless serve mode, exposing a web GUI for AI coding agents (Claude, Codex, etc.) on port 3773. Claude Code gets full admin access to manage the HA instance — edit configs, call services, manage automations, query state. Deploy to homeassistant.tomsawyerlabs.com.

## Environment / Context

- **HA instance**: homeassistant.tomsawyerlabs.com
- **Project repo**: `C:\Users\camer\git\Personal Projects\t3ha` (GitHub: `cinderblock/hat3`)
- **t3 package**: npm `t3` (from pingdotgg/t3code) — web GUI for coding agents
- **t3 serve mode**: `t3 serve --host 0.0.0.0 --port 3773` — headless, prints pairing token to stdout
- **Node.js requirement**: >= 22.16 (t3 dependency)
- **node-pty**: native addon, needs build tools (gcc, make, python3) to compile on Linux
- **Claude Code**: needed as subprocess for t3's Claude provider; installed via npm `@anthropic-ai/claude-code`
- **Auth**: Claude Code uses OAuth — run `claude /quit` inside the container to authenticate
- **Reference script**: https://isozilla.com/t3.sh — user's existing server setup (systemd-based, bun, OAuth); NOT used directly, fresh HA-specific implementation

## Decisions Already Made (don't re-ask)

- **Single add-on** bundling t3 + Claude Code (not separate add-ons; t3 shells out to claude as a subprocess, they must share a container)
- **Direct port mapping** on 3773 (not ingress — t3 expects root path, has its own pairing auth, WebSocket-heavy)
- **npm** for package installation (not bun — more reliable on Alpine/musl)
- **HA base image** (Alpine) with apk-installed Node.js + build tools
- **OAuth auth** for Claude Code — `docker exec` into container to authenticate, credentials persist in `/data/.claude`
- **`/data`** for persistent storage (t3 home, claude config) — survives container rebuilds
- **Full admin access** — config:rw, share:rw, ssl:ro, media:rw, backup:rw, addons:ro, homeassistant_api, hassio_api (admin role), auth_api
- **CWD = /config** so Claude Code operates directly on HA configuration
- **CLAUDE.md in /config** with HA API docs, helper script usage, config patterns — auto-installed on first start
- **`ha` helper script** in container — curl wrapper for Supervisor/Core API with auto-auth

## Plan / Steps

1. [x] Research t3 serve mode (CLI flags, token output, auth, Claude dependency)
2. [x] Research HA add-on structure (config.yaml, Dockerfile, S6, ports, ingress, repository.yaml)
3. [x] Fetch user's existing setup script for reference
4. [x] Create plan document
5. [x] Create repository structure (repository.yaml, README.md)
6. [x] Create add-on config (config.yaml, build.yaml)
7. [x] Create Dockerfile (Node.js 22, build tools, t3, claude-code, jq, openssh-client)
8. [x] Create run.sh entry point (persistent storage, API key, CLAUDE.md install, CWD=/config)
9. [x] Create `ha` helper script (rootfs/usr/local/bin/ha)
10. [x] Create CLAUDE.md template (rootfs/etc/t3code/CLAUDE.md) with full HA management docs
11. [x] Create docs (DOCS.md, CHANGELOG.md, translations/en.yaml)
12. [x] Initialize git, verify structure
13. [ ] Push to GitHub and add as custom repo in HA ← next: user action

## Findings / Gotchas

- **node-pty has no Linux prebuilds** — must compile from source via node-gyp. Needs `build-base python3` in Alpine. The setup script works around this extensively.
- **Alpine uses musl** — official Node.js binaries are glibc. Must use Alpine's `nodejs` package or unofficial musl builds. Alpine 3.21 should have Node 22.x (LTS since Oct 2024).
- **t3 serve prints pairing info to stdout** — token, pairing URL, QR code. All stdout goes to HA add-on logs automatically.
- **`t3 auth pairing create --base-url URL`** can mint additional pairing tokens after startup, useful if the initial token is lost.
- **Ingress would break t3** — t3 expects root path, uses WebSockets extensively, has its own auth. Direct port mapping is the right call.
- **`T3CODE_HOME` env var** controls where t3 stores data (auth, sessions, projects). Set to `/data/t3code` for persistence.
- **SUPERVISOR_TOKEN** is auto-injected by HA into the container env. The `ha` helper uses it for auth.
- **CLAUDE.md is only copied on first start** — if user or Claude modifies it, changes persist. Delete it manually to reset to template.
- **npm `@anthropic-ai/claude-code` is a JS wrapper, NOT the native binary** — t3's agent SDK (v0.2.141+) spawns `claude` as a subprocess and communicates via stream-JSON over stdin/stdout. The JS npm wrapper doesn't support this protocol properly.
- **SDK/CLI version alignment is critical** — The SDK's `package.json` has a `claudeCodeVersion` field (e.g., `"2.1.141"` for SDK 0.2.141). The curl installer always downloads the LATEST binary (currently 2.1.143), causing a mismatch. Fix: use the SDK's bundled binary from `@anthropic-ai/claude-agent-sdk-linux-x64-musl` optional dependency — it's version-matched by design.
- **T3 bypasses SDK binary resolution** — T3 passes `pathToClaudeCodeExecutable: "claude"` (bare name, resolved via PATH) to the SDK, which skips the SDK's own platform package lookup. So the binary on PATH must be the correct version.
- **T3 default mode is `full-access`** → `permissionMode: "bypassPermissions"` + `allowDangerouslySkipPermissions: true` + `canUseTool` callback (adds `--permission-prompt-tool stdio` flag).
- **SDK spawn flags**: `--output-format stream-json --input-format stream-json --verbose --permission-mode bypassPermissions --allow-dangerously-skip-permissions --permission-prompt-tool stdio --setting-sources user,project,local`
- **SDK env vars**: `CLAUDE_CODE_ENTRYPOINT=sdk-ts`, `CLAUDE_AGENT_SDK_VERSION=0.2.141`
- **`/root/.claude.json`** also needs persistence — it's a separate file from the `/root/.claude/` directory. Added symlink-to-`/data` logic in run.sh.
- **SDK 0.3.x exists** (latest 0.3.143) but T3's dep range `^0.2.111` caps at 0.2.141. Breaking changes in 0.3.x: removed V2 session API, TodoWrite→Task* tools, MCP connection behavior. The `query()` API T3 uses is preserved.

## Things Not to Do

- Don't use ingress — t3's WebSocket/auth model doesn't play well with HA's ingress proxy
- Don't use bun — npm is more reliable on Alpine musl
- Don't install Claude Code via npm (`@anthropic-ai/claude-code`) — the npm package is a JS wrapper that doesn't support the stream-JSON protocol the agent SDK uses.
- Don't use `curl -fsSL https://claude.ai/install.sh | bash` for the claude binary — it always installs the LATEST version, which may not match the SDK's expected `claudeCodeVersion`. Use the SDK's bundled binary from its optional platform dependency instead.
- Don't overwrite CLAUDE.md on restart — only install if missing
