# T3 Code

T3 Code is a web GUI for AI coding agents. It supports Claude (via Claude Code), Codex, OpenCode, and more.

This add-on runs T3 Code in headless serve mode with full Home Assistant management access — Claude Code can edit configs, call services, manage automations, and control your HA instance.

## Setup

1. **Start the add-on** and check the **Log** tab for the pairing URL.
2. **Pair your browser**: Copy the `Pairing URL:` from the logs and open it in your browser.
3. **Authenticate Claude**: Open a terminal to the add-on container and log in:
   ```
   ha addons exec local_t3code -- claude /quit
   ```
   Follow the OAuth prompts — visit the URL, paste the code. Credentials persist across restarts.
4. You're ready — create a Claude session in the T3 web UI.

## Port

The web interface runs on port **3773** by default. Access it at `http://<your-ha-ip>:3773` after pairing.

## What Claude Can Do

This add-on gives Claude Code full admin access to your HA instance:

- **Edit configuration** — `configuration.yaml`, automations, scripts, scenes, and all config files
- **Call services** — turn lights on/off, trigger automations, control any entity
- **Read state** — query entity states, check sensor values, view device info
- **Manage system** — restart HA, reload configs, view supervisor/host info, manage add-ons and backups
- **Access files** — read/write `/config`, `/share`, `/media`; read `/ssl`, `/addons`

A `CLAUDE.md` is automatically installed in `/config` on first start, giving Claude Code context about available APIs and HA patterns.

A `ha` helper script is available inside the container for quick API calls.

## Claude Authentication

Claude uses OAuth — no API keys needed. Authenticate once and credentials persist in `/data/.claude` across add-on updates and restarts.

**To authenticate (first time or after token expiry):**

```bash
# Via HA CLI (from Terminal & SSH add-on):
ha addons exec local_t3code -- claude /quit

# Or via Docker (from host SSH):
docker exec -it addon_local_t3code claude /quit
```

Follow the prompts: visit the URL, authorize, paste the code back. The `/quit` flag exits Claude after login completes.

**To check auth status:**

```bash
ha addons exec local_t3code -- claude auth status
```

## Pairing Tokens

The T3 pairing token is printed to logs on startup. If you need a new one:

- **Restart** the add-on — a fresh token is printed each time.

## Data Persistence

- **T3 data** (sessions, auth, projects) is stored in `/data/t3code` and survives add-on updates.
- **Claude credentials** are stored in `/data/.claude`.
- **HA config** is at `/config` (the real HA config directory, read/write).
- **Shared files** live in `/share`, accessible from other add-ons and via Samba/SSH.

## Providers

T3 Code supports multiple AI coding agent backends:

- **Claude** — authenticate via OAuth (see above)
- **Codex** — configure via the T3 web UI after pairing
- **OpenCode** — configure via the T3 web UI after pairing

## Troubleshooting

- **No pairing URL in logs**: Wait 10-20 seconds after start for t3 to initialize. If still missing, check for errors above the expected output.
- **Claude provider not working**: Check auth status (see above). If expired, re-authenticate and restart the add-on.
- **Port conflict**: If port 3773 is already in use, change the host port mapping in the add-on Network configuration.
- **Config changes not taking effect**: Use the T3 web UI to ask Claude to validate and reload the config, or restart HA from the Supervisor panel.
