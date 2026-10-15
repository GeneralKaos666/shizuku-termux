# Attribution — ideias de origem (não copiamos código GPL)

Este núcleo funde capacidades únicas de wrappers comunitários, reimplementando
o que necessário. Nenhum arquivo GPL foi copiado. Lista de atribuição:

| Fonte | O que foi aproveitado | Como entrou no núcleo |
|-------|----------------------|----------------------|
| RikkaApps/Shizuku | launcher `app_process` + `ShizukuShellLoader`, chmod 400, DEX ao lado do script | Reimplementado (asset oficial); classe FQCN `rikka.shizuku.shell.ShizukuShellLoader` |
| merbah3266/rish_installer | unzip `assets/rish` + `assets/rish_shizuku.dex`, `install -m755`/`install -m400`, detect package id | `src/lib/extract-apk.sh` (reimplementado; tinyurl recusado) |
| AlexeiCrystal/termux-shizuku-tools | verbos `info|open|stop|exec|shell|version|doctor|install|uninstall`, `.deb` sem dex/so, CLI `shizuku`/`shk` | `src/bin/shizuku`, `src/packaging/build-deb.sh` (binários não copiados) |
| jecis-repos/termux-shizuku-tools | keepalive / phantom process, aliases `spm`/`sam` | `src/plugins/keepalive.sh` (loop heartbeat, reimplementado), `src/plugins/aliases.sh` |
| orzgithub/rish4termux | switch `--shizuku`/`--sui` | `src/plugins/sui.sh` (reimplementado; arquivo GPL não copiado) |
| hxse/termux-shizuku-bootstrap | wireless pair/connect (IP:porta + código) | `src/plugins/wireless.sh` (127.0.0.1 recusado; `curl|bash` recusado) |
| xvxv-stack7/termux-shizuku | usb-loopback `adb tcpip 5555` + `connect 127.0.0.1:5555` | `src/plugins/usb-loopback.sh` |
| austinsager/adv-install | `pm install` só se uid 2000 | `src/plugins/pm-install.sh` (via `rish -c "pm install ..."`) |
| ConzZah/csb | start daemon Shizuku via adb | `src/plugins/start-daemon.sh` (start.sh oficial; não instala rish) |
| duckofduckers/Rish-PackageManager | fluxo install/uninstall | `st_install`/`st_uninstall` (tinyurl recusado) |
| aliyoariel/shizuku-termux-installer | path absoluto do DEX no launcher | `src/bin/rish.in` (`@DEX@` injetado; gist/`curl|bash` recusado) |

## Ideia aproveitada (não consumidor, entra no núcleo)

| Fonte | O que foi aproveitado | Onde |
|-------|-------------------|------|
| crowforkotlin/quick-shell | `--source latest` (download APK oficial via GitHub API) + fallback `libshizuku.so --apk=` para start do daemon; `adb-connect` (debug sem fio em 127.0.0.1 sem tcpip) + `wf` (abre Wireless Debugging) | `src/lib/extract-apk.sh` (`st_download_official_apk`), `src/plugins/start-daemon.sh`, `src/plugins/adb-connect.sh` |
| auto-brevent (ideia) | `wait`: poll `rish -c true` até Shizuku responder | `src/lib/doctor.sh` (`st_wait`) |

## Veneno recusado (não entra no núcleo)
tinyurl, `curl … | bash`, `gist … | bash`, DEX/`.so` no git, `chmod +w/+rwx` no DEX,
`releases/latest/download/rish`, `pkg install shizuku`, `PKG` placeholder vivo,
arquivo GPL do rish4termux.

## Consumidores (apenas docs, sem vendor)
MCP, Telegram, Lucky Patcher, game booster — veja `docs/consumers.md`.
