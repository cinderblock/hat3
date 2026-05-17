# Changelog

## 0.3.2

- Fix startup crash: guard diagnostic test against bashio's `set -e` (non-zero exit from test was aborting run.sh)

## 0.3.1

- Use SDK-bundled Claude binary instead of separate curl install — ensures exact version alignment between SDK (0.2.141) and CLI (2.1.141), fixing `setPermissionMode` exit code 1
- Add startup diagnostic: tests Claude in agent-SDK mode and logs results

## 0.3.0

- Switch Claude Code from npm JS wrapper to native binary installer — fixes agent SDK crash (`setPermissionMode` exit code 1)
- Persist `/root/.claude.json` across container rebuilds (symlinked to `/data`)

## 0.2.0

- Switch from API key to Claude OAuth login (no API keys needed)
- Add auth status check on startup with instructions if not logged in
- Enable `stdin` for container shell access

## 0.1.0

- Initial release
- Runs t3 serve on port 3773 with Claude Code pre-installed
- Pairing token printed to add-on logs on startup
- Persistent storage for t3 data and Claude credentials
- Full HA management access (config, API, supervisor)
- `ha` helper script for quick API calls
- `CLAUDE.md` template with HA management context
