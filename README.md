# shizuku-termux

Single CLI (`shizuku` / `shk` / `rish`) that installs, validates and uses Shizuku/`rish` in Termux within the official Rikka protocol, fusing the unique capabilities of the community wrappers and refusing rotten supply-chain practices.

## Requirements

- Termux (F-Droid or Play Store) installed on the device
- Official Shizuku app (`moe.shizuku.privileged.api`) installed and started
- `unzip`, `bash`, `curl` available in Termux

## Installation on the device

```bash
# Extracts the DEX and the launcher from the already installed Shizuku APK
shizuku install

# Or from a local APK file
shizuku install --apk /path/to/Shizuku.apk

# Or download the latest official release from Rikka's GitHub
shizuku install --source latest

# Check the health of the bridge
shizuku doctor
```

## CLI verbs

| Verb | What it does |
|------|--------------|
| `install [--apk <path>] \| --source latest` | Extracts `rish` + `rish_shizuku.dex` (+ `librish.so`, `rish_sui.dex`) from the APK; creates `$PREFIX/bin/rish` |
| `doctor` | Checks: APK, DEX exists, DEX non-writable, `RISH_APPLICATION_ID`, `rish -c id` |
| `rish <args>` | Passes args to the remote launcher |
| `shizuku` / `shk` | `info\|open\|stop\|exec <cmd>\|shell\|version\|doctor\|install\|uninstall` |
| `uninstall` | Removes launcher/DEX/tree/symlink (no tinyurl) |
| `sui --backend shizuku\|sui` | Backend switch (default shizuku) |
| `wireless --target IP:port --code XXX` | Pairs adb over wireless (NOT 127.0.0.1) |
| `usb-loopback` | `adb tcpip 5555` + `connect 127.0.0.1:5555` |
| `keepalive start\|stop\|status` | Heartbeat: reruns start.sh if `rish -c id` fails |
| `pm-install <apk>` | Installs an APK via `rish` only if `uid 2000` |
| `start-daemon` | Starts the Shizuku daemon via the official `start.sh` (adb) |
| `adb-connect <port>` | Connects wireless debugging on 127.0.0.1:PORT (no tcpip) |
| `adb-connect pair <port> <code>` | Pairs adb over wireless on 127.0.0.1 |
| `adb-connect status` | Lists adb devices |
| `adb-connect disconnect [port]` | Disconnects (default 5555) |
| `adb-connect wf` | Opens the Wireless Debugging screen (`am start`) |
| `wait [seconds]` | Waits for Shizuku to respond via `rish -c true` (default 60s) |
| `aliases` | Shows the optional `spm`/`sam` |
| `help` | This help |

## Layout after install

```
$PREFIX/lib/shizuku-termux/
  rish               real launcher (generated from rish.in; PKG never stays alive)
  rish.in            launcher template
  rish_shizuku.dex   chmod 400 (non-writable)
  rish_sui.dex       chmod 400 (optional, Sui backend)
  librish.so         optional, extracted from the APK
  backend            "shizuku" or "sui"
  lib/               paths.sh, extract-apk.sh, doctor.sh (sourced by the CLI)
  plugins/           sui, wireless, keepalive, usb-loopback, pm-install,
                     start-daemon, adb-connect, aliases
$PREFIX/bin/rish     3-line wrapper: execs the real one in lib/
$PREFIX/bin/shizuku  copy of the CLI (dispatch by $0)
$PREFIX/bin/shk      copy of the CLI (dispatch by $0)
```

## What is not included (refused poison)

- `tinyurl`, `curl … | bash`, `gist … | bash`
- DEX / `.so` committed to git
- `chmod +w` / `+rwx` on the DEX
- `releases/latest/download/rish` / fake releases
- `pkg install shizuku`
- Live `PKG` placeholder
- GPL file from rish4termux (the switch is reimplemented, not copied)

## Companion: termux-adb

The `wireless`, `usb-loopback`, `adb-connect` and `start-daemon` verbs resolve the `adb` binary through `st_adb` (defined in `src/lib/paths.sh`). The resolution order is:

1. Environment variable `ST_ADB` (test override).
2. `~/.local/bin/adb` — unified front-end of [rianprei/termux-adb](https://github.com/rianprei/termux-adb), which routes OTG (`termux-adb` + termux-usb) vs native (`$PREFIX/bin/adb`).
3. `command -v adb` (PATH).
4. `$PREFIX/bin/termux-adb` (last resort, OTG patched).

No installer or binary from termux-adb is vendored in this repository.

## License and attribution

Own code under the [MIT License](LICENSE). Ideas originating from the community wrappers are in [ATTRIBUTION.md](ATTRIBUTION.md).

## Development

The tests run on the host (no device):

```bash
bash tests/run-all.sh
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for pull request rules.
