# Consumers — documentation only

The consumers below are NOT a dependency of the shizuku-termux core.
They appear only as reference documentation. If any of them is
enabled, it enters as a plugin in `plugins/consumers/`, default off, without
vendoring of third-party binaries.

| Consumer | What it does | Status in the core |
|----------|--------------|--------------------|
| MCP (shizuku-mcp) | Exposes the Shizuku shell to an LLM via MCP | Outside the core; optional plugin, default off |
| Telegram | Bot/bridge for Shizuku commands | Outside the core; optional plugin, default off |
| Lucky Patcher | App modification | Outside the core; not a dependency |
| game booster | Game optimization via Shizuku | Outside the core; not a dependency |
| celaya-solutions/android-claude-code-mcp-server | MCP + droid-sh for Claude Code | Outside the core; not a dependency |
| SysopBP/Shizuku-TokenX | Multi-backend fork; own DEX; --root/--system/--shell | Outside the core; not a dependency |
| ahmed-alnassif/AndroSH | Shizuku client for Android | Outside the core; not a dependency |
| Qutaiba-Khader/Shizuku-Tools | Java Force Stop app, not a Termux installer | Outside the core; not a dependency |
| light (quick-shell) | `light <minutes>` adjusts `screen_off_timeout` via `rish -c` | Consumer: consumes an already installed rish, it is not a bridge; outside the core |

## Idea (not a consumer, enters the core as a source)

| Repo | Idea leveraged | Where |
|------|----------------|-------|
| crowforkotlin/quick-shell | `--source latest` + `libshizuku.so --apk=` fallback; `adb-connect` (wireless debugging on 127.0.0.1 without tcpip) + `wf` (opens Wireless Debugging) | `src/lib/extract-apk.sh` (`st_download_official_apk`), `src/plugins/start-daemon.sh`, `src/plugins/adb-connect.sh` |
| auto-brevent (idea) | `wait`: poll `rish -c true` until Shizuku responds | `src/lib/doctor.sh` (`st_wait`) |

## Rule
No consumer enters the main `src/`. Any future integration must be an
isolated plugin in `plugins/consumers/<name>/`, controlled by `ST_PLUGINS`,
default off, and must never include third-party binaries (vendoring forbidden).
