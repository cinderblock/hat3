# T3 Code — Home Assistant Add-on Repository

Home Assistant add-on that runs [T3 Code](https://github.com/pingdotgg/t3code), a web GUI for AI coding agents (Claude, Codex, and more).

## Installation

1. In Home Assistant, go to **Settings > Add-ons > Add-on Store**
2. Click the three-dot menu (top right) > **Repositories**
3. Paste this repository URL and click **Add**:
   ```
   https://github.com/cinderblock/hat3
   ```
4. Find **T3 Code** in the store and click **Install**
5. In the add-on **Configuration** tab, set your `anthropic_api_key`
6. Start the add-on
7. Check the **Log** tab for the pairing token/URL — use it to connect your browser to the t3 instance

## Add-ons

### [T3 Code](./t3code)

Runs `t3 serve` on port 3773 with Claude Code pre-installed. Prints a one-time pairing token to the logs on startup. Visit the pairing URL to connect.

## Pairing After First Start

The pairing URL (with token) appears in the add-on logs on every fresh start. If you need a new token later:

1. Open the add-on **Log** tab
2. Look for the line: `Pairing URL: http://...`
3. If the token has expired, restart the add-on to generate a new one

You can also use `t3 auth pairing create` from within the container terminal.
