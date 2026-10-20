# Attribution — ideas of origin (we do not copy GPL code)

This core fuses unique capabilities from community wrappers, reimplementing
what is necessary. No GPL file was copied. Attribution list:

| Source | What was leveraged | How it entered the core |
|--------|--------------------|-------------------------|
| RikkaApps/Shizuku | `app_process` launcher + `ShizukuShellLoader`, chmod 400, DEX next to the script | Reimplemented (official asset); FQCN class `rikka.shizuku.shell.ShizukuShellLoader` |
| merbah3266/rish_installer | unzip `assets/rish` + `assets/rish_shizuku.dex`, `install -m755`/`install -m400`, detect package id | `src/lib/extract-apk.sh` (reimplemented; tinyurl refused) |
| AlexeiCrystal/termux-shizuku-tools | verbs `info|open|stop|exec|shell|version|doctor|install|uninstall`, `.deb` without dex/so, CLI `shizuku`/`shk` | `src/bin/shizuku`, `src/packaging/build-deb.sh` (binaries not copied) |
| jecis-repos/termux-shizuku-tools | keepalive / phantom process, `spm`/`sam` aliases | `src/plugins/keepalive.sh` (heartbeat loop, reimplemented), `src/plugins/aliases.sh` |
| orzgithub/rish4termux | `--shizuku`/`--sui` switch | `src/plugins/sui.sh` (reimplemented; GPL file not copied) |
| hxse/termux-shizuku-bootstrap | wireless pair/connect (IP:port + code) | `src/plugins/wireless.sh` (127.0.0.1 refused; `curl|bash` refused) |
| xvxv-stack7/termux-shizuku | usb-loopback `adb tcpip 5555` + `connect 127.0.0.1:5555` | `src/plugins/usb-loopback.sh` |
| austinsager/adv-install | `pm install` only if uid 2000 | `src/plugins/pm-install.sh` (via `rish -c "pm install ..."`) |
| ConzZah/csb | start Shizuku daemon via adb | `src/plugins/start-daemon.sh` (official start.sh; does not install rish) |
| duckofduckers/Rish-PackageManager | install/uninstall flow | `st_install`/`st_uninstall` (tinyurl refused) |
| aliyoariel/shizuku-termux-installer | absolute DEX path in the launcher | `src/bin/rish.in` (`@DEX@` injected; gist/`curl|bash` refused) |

## Idea leveraged (not a consumer, enters the core)

| Source | What was leveraged | Where |
|--------|--------------------|-------|
| crowforkotlin/quick-shell | `--source latest` (download the official APK via GitHub API) + `libshizuku.so --apk=` fallback to start the daemon; `adb-connect` (wireless debugging on 127.0.0.1 without tcpip) + `wf` (opens Wireless Debugging) | `src/lib/extract-apk.sh` (`st_download_official_apk`), `src/plugins/start-daemon.sh`, `src/plugins/adb-connect.sh` |
| auto-brevent (idea) | `wait`: poll `rish -c true` until Shizuku responds | `src/lib/doctor.sh` (`st_wait`) |
| GeneralKaos666/shizuku-termux | `tests/run-all.sh`, whole-suite CI, `${TMPDIR:-/tmp}`, `umask 022` in build-deb | reimplemented; EN translation refused |
| rianprei/termux-adb | unified `adb` front-end (OTG + native); binary resolution via `st_adb` | `src/lib/paths.sh` (`st_adb_bin`, `st_adb`); code not copied |

## Refused poison (does not enter the core)
tinyurl, `curl … | bash`, `gist … | bash`, DEX/`.so` in git, `chmod +w/+rwx` on the DEX,
`releases/latest/download/rish`, `pkg install shizuku`, live `PKG` placeholder,
GPL file from rish4termux.

## Consumers (docs only, no vendor)
MCP, Telegram, Lucky Patcher, game booster — see `docs/consumers.md`.
