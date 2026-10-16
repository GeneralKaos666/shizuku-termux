# SPEC — Shizuku-for-Termux Fusion (core)

Single contract of the `shizuku` / `shk` / `rish` CLI. Approved by the owner. Union of the capabilities; poison is still refused.

## 1. Paths (mandatory)

| Item | Path | Notes |
|------|------|-------|
| Lib directory | `$PREFIX/lib/shizuku-termux/` | `$PREFIX` = Termux prefix |
| Real launcher | `$PREFIX/lib/shizuku-termux/rish` | POSIX sh script, generated from `src/bin/rish.in` |
| DEX | `$PREFIX/lib/shizuku-termux/rish_shizuku.dex` | `chmod 400` (non-writable) |
| Native lib | `$PREFIX/lib/shizuku-termux/librish.so` | optional, extracted from the APK if present |
| Bin entry | `$PREFIX/bin/rish` | 3-line wrapper that `exec`s the real launcher in `lib/shizuku-termux/rish`. |
| CLI symlink | `$PREFIX/bin/shizuku` | copy of the CLI `src/bin/shizuku` (dispatch by `$0`). |
| CLI symlink | `$PREFIX/bin/shk` | copy of the CLI `src/bin/shizuku` (dispatch by `$0`). |

## 2. Environment variables

| Variable | Default value | Required? |
|----------|---------------|-----------|
| `RISH_APPLICATION_ID` | `$TERMUX_APP__PACKAGE_NAME` if set, otherwise `com.termux` | YES. Never `PKG`. |
| `RISH_PRESERVE_ENV` | Not set by the wrapper. The Shizuku Java loader honors it if the user exports it; this wrapper does not apply a default `0`/`1`. | No. |
| `ST_ADB` | Override of the `adb` binary for tests. If set and executable, `st_adb` uses that path. | No. |
| `ST_PLUGINS` | Not used in the core. All bridge plugins always load; it only affects future plugins in `plugins/consumers/`. |

## 3. Exit codes (no collision)

| Code | Meaning |
|------|---------|
| `0` | OK |
| `1` | Invalid usage / missing argument |
| `2` | Shizuku down (not responding / not installed) |
| `3` | DEX writable / A14 (SDK ≥ 34 with writable DEX) |
| `4` | Shizuku APK not found (`moe.shizuku.privileged.api`) |
| `5` | Unexpected UID (`rish -c id` is neither 2000 nor 0) |
| `6` | DEX or launcher missing |

## 4. Verbs (single CLI `shizuku` / `shk` / `rish`)

| Verb | Does |
|------|------|
| `install [--apk <file>|--source latest]` | Extracts APK → `$PREFIX/lib/shizuku-termux/{rish,rish_shizuku.dex,librish.so?}`; `--apk` uses a local file; `--source latest` downloads the official `*.apk` from the RikkaApps/Shizuku release (GitHub API, never `releases/latest/download/rish`); with neither and no `pm`: exit 4. |
| `doctor` | Shizuku up? dex exists? dex non-writable? RISH_APPLICATION_ID? `rish -c id` → uid |
| `rish` | Launcher; fails if dex is writable or missing |
| `shizuku` / `shk` | `info|open|stop|exec|shell|version|doctor|install|uninstall|adb-connect|wait` |
| `sui` | `--backend shizuku|sui` (default shizuku) |
| `wireless` | `adb pair/connect IP:port + code` (NOT 127.0.0.1) |
| `usb-loopback` | `adb tcpip 5555` + `connect 127.0.0.1:5555` |
| `keepalive` | Mitigates phantom process |
| `pm-install` | `pm install` only if `rish -c id` is uid 2000 |
| `start-daemon` | Start the Shizuku daemon via adb (does not replace the app; does not install rish) |
| `adb-connect` | Wireless debugging on 127.0.0.1: port | pair | status | disconnect | wf |
| `wait` | Waits for Shizuku to respond via `rish -c true` (60s timeout, env `ST_WAIT_TIMEOUT`) |
| `aliases` | Optional `spm`/`sam` aliases (plugin) |
| `uninstall` | Cleans launcher/dex/symlink, no tinyurl |

## 5. Bridge plugins (always present; do not depend on ST_PLUGINS)

`sui`, `wireless`, `keepalive`, `usb-loopback`, `pm-install`, `start-daemon`, `aliases`, `adb-connect`.

ST_PLUGINS only serves `plugins/consumers/` (MCP, Telegram, Lucky Patcher, game booster) — default off, no vendoring of third-party binaries.

## 6. Refusals (poison, never enters the core)

- `tinyurl`, `curl … | bash`, `gist … | bash`
- DEX / `.so` committed to git
- `chmod +w` / `+rwx` on the DEX
- `releases/latest/download/rish` / fake releases (including `install --source latest`, which only accepts an `*.apk` APK, never the `rish` asset)
- `pkg install shizuku`
- Live `PKG` placeholder
- GPL file from rish4termux (reimplement the switch, do not copy)

## 7. ABI mapping (uname -m → arm ABI of the APK)

`aarch64 → arm64-v8a`, `armv7l|armv8l → armeabi-v7a`, `x86_64 → x86_64`, `i686 → x86`. No match: skip `.so` + warning.
