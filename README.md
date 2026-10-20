# shizuku-termux

Único CLI (`shizuku` / `shk` / `rish`) que instala, valida e usa o Shizuku/`rish` no Termux dentro do protocolo oficial da Rikka, fundindo as capacidades únicas dos wrappers comunitários e recusando supply-chain podre.

## Requisitos

- Termux (F-Droid ou Play Store) instalado no dispositivo
- Aplicativo Shizuku oficial (`moe.shizuku.privileged.api`) instalado e iniciado
- `unzip`, `bash`, `curl` disponíveis no Termux

## Instalação no device

```bash
# Extrai o DEX e o launcher do APK Shizuku já instalado
shizuku install

# Ou a partir de um arquivo APK local
shizuku install --apk /caminho/para/Shizuku.apk

# Ou baixa o release oficial mais recente do GitHub da Rikka
shizuku install --source latest

# Verifique a saúde da ponte
shizuku doctor
```

## Verbos do CLI

| Verbo | O que faz |
|-------|-----------|
| `install [--apk <caminho>] \| --source latest` | Extrai `rish` + `rish_shizuku.dex` (+ `librish.so`, `rish_sui.dex`) do APK; cria `$PREFIX/bin/rish` |
| `doctor` | Checa: APK, DEX existe, DEX não-gravável, `RISH_APPLICATION_ID`, `rish -c id` |
| `rish <args>` | Passa args ao launcher remoto |
| `shizuku` / `shk` | `info\|open\|stop\|exec <cmd>\|shell\|version\|doctor\|install\|uninstall` |
| `uninstall` | Remove launcher/DEX/árvore/symlink (sem tinyurl) |
| `sui --backend shizuku\|sui` | Switch de backend (default shizuku) |
| `wireless --target IP:porta --code XXX` | Emparelha adb via wireless (NÃO 127.0.0.1) |
| `usb-loopback` | `adb tcpip 5555` + `connect 127.0.0.1:5555` |
| `keepalive start\|stop\|status` | Heartbeat: reexecuta start.sh se `rish -c id` falhar |
| `pm-install <apk>` | Instala APK via `rish` só se `uid 2000` |
| `start-daemon` | Inicia daemon Shizuku via `start.sh` oficial (adb) |
| `adb-connect <porta>` | Conecta debug sem fio em 127.0.0.1:PORTA (sem tcpip) |
| `adb-connect pair <porta> <codigo>` | Emparelha adb sem fio em 127.0.0.1 |
| `adb-connect status` | Lista dispositivos adb |
| `adb-connect disconnect [porta]` | Desconecta (default 5555) |
| `adb-connect wf` | Abre tela de Wireless Debugging (`am start`) |
| `wait [segundos]` | Espera Shizuku responder via `rish -c true` (default 60s) |
| `aliases` | Mostra `spm`/`sam` opcionais |
| `help` | Esta ajuda |

## Layout após o install

```
$PREFIX/lib/shizuku-termux/
  rish               launcher real (gerado de rish.in; PKG nunca fica vivo)
  rish.in            template do launcher
  rish_shizuku.dex   chmod 400 (não-gravável)
  rish_sui.dex       chmod 400 (opcional, backend Sui)
  librish.so         opcional, extraído do APK
  backend            "shizuku" ou "sui"
  lib/               paths.sh, extract-apk.sh, doctor.sh (sourcados pelo CLI)
  plugins/           sui, wireless, keepalive, usb-loopback, pm-install,
                     start-daemon, adb-connect, aliases
$PREFIX/bin/rish     wrapper de 3 linhas: exec do real em lib/
$PREFIX/bin/shizuku  cópia do CLI (dispatch por $0)
$PREFIX/bin/shk      cópia do CLI (dispatch por $0)
```

## Companheiro: termux-adb

Os verbos `wireless`, `usb-loopback`, `adb-connect` e `start-daemon` resolvem o binário `adb` através de `st_adb` (definido em `src/lib/paths.sh`). A ordem de resolução é:

1. Variável de ambiente `ST_ADB` (override para testes).
2. `~/.local/bin/adb` — front-end unificado do [rianprei/termux-adb](https://github.com/rianprei/termux-adb), que roteia OTG (`termux-adb` + termux-usb) vs nativo (`$PREFIX/bin/adb`).
3. `command -v adb` (PATH).
4. `$PREFIX/bin/termux-adb` (último recurso, patchado OTG).

Nenhum instalador ou binário do termux-adb é vendido neste repositório.

## Licença e atribuição

Código próprio sob [MIT License](LICENSE). Ideias de origem dos wrappers comunitários em [ATTRIBUTION.md](ATTRIBUTION.md).

## Desenvolvimento

Os testes rodam no host (sem device):

```bash
bash tests/run-all.sh
```

Veja [CONTRIBUTING.md](CONTRIBUTING.md) para regras de pull request.
