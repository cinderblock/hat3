# Changelog

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
