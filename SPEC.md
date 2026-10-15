# SPEC — Shizuku-for-Termux Fusion (núcleo)

Contrato único do CLI `shizuku` / `shk` / `rish`. Aprovado pelo dono. União das capacidades; veneno continua recusado.

## 1. Paths (obrigatório)

| Item | Caminho | Notas |
|------|---------|-------|
| Diretório lib | `$PREFIX/lib/shizuku-termux/` | `$PREFIX` = prefixo do Termux |
| Launcher real | `$PREFIX/lib/shizuku-termux/rish` | script POSIX sh, gerado de `src/bin/rish.in` |
| DEX | `$PREFIX/lib/shizuku-termux/rish_shizuku.dex` | `chmod 400` (não-gravável) |
| Native lib | `$PREFIX/lib/shizuku-termux/librish.so` | opcional, extraída do APK se existir |
| Entrada bin | `$PREFIX/bin/rish` | wrapper de 3 linhas que `exec` o launcher real em `lib/shizuku-termux/rish`. |
| Symlink CLI | `$PREFIX/bin/shizuku` | cópia do CLI `src/bin/shizuku` (dispatch por `$0`). |
| Symlink CLI | `$PREFIX/bin/shk` | cópia do CLI `src/bin/shizuku` (dispatch por `$0`). |

## 2. Variáveis de ambiente

| Variável | Valor padrão | Obrigatório? |
|----------|-------------|--------------|
| `RISH_APPLICATION_ID` | `$TERMUX_APP__PACKAGE_NAME` se set, senão `com.termux` | SIM. Nunca `PKG`. |
| `RISH_PRESERVE_ENV` | Não definido pelo wrapper. O loader Java do Shizuku honra se o usuário exportar; este wrapper não aplica default `0`/`1`. | Não. |
| `ST_ADB` | Override do binário `adb` para testes. Se definido e executável, `st_adb` usa esse caminho. | Não. |
| `ST_PLUGINS` | Não usado no núcleo. Todos os plugins de ponte carregam sempre; afeta apenas plugins futuros em `plugins/consumers/`. |

## 3. Exit codes (sem colisão)

| Código | Significado |
|--------|-------------|
| `0` | OK |
| `1` | Uso inválido / argumento faltando |
| `2` | Shizuku down (não responde / não instalado) |
| `3` | DEX gravável / A14 (SDK ≥ 34 com DEX writable) |
| `4` | APK Shizuku não encontrado (`moe.shizuku.privileged.api`) |
| `5` | UID inesperado (`rish -c id` não é 2000 nem 0) |
| `6` | DEX ou launcher ausente |

## 4. Verbos (único CLI `shizuku` / `shk` / `rish`)

| Verbo | Faz |
|-------|-----|
| `install [--apk <arquivo>|--source latest]` | Extrai APK → `$PREFIX/lib/shizuku-termux/{rish,rish_shizuku.dex,librish.so?}`; `--apk` usa arquivo local; `--source latest` baixa APK oficial `*.apk` do release RikkaApps/Shizuku (GitHub API, nunca `releases/latest/download/rish`); sem nenhum dos dois e sem `pm`: exit 4. |
| `doctor` | Shizuku up? dex existe? dex non-writable? RISH_APPLICATION_ID? `rish -c id` → uid |
| `rish` | Launcher; falha se dex writable ou ausente |
| `shizuku` / `shk` | `info|open|stop|exec|shell|version|doctor|install|uninstall|adb-connect|wait` |
| `sui` | `--backend shizuku|sui` (default shizuku) |
| `wireless` | `adb pair/connect IP:porta + código` (NÃO 127.0.0.1) |
| `usb-loopback` | `adb tcpip 5555` + `connect 127.0.0.1:5555` |
| `keepalive` | Mitiga phantom process |
| `pm-install` | `pm install` só se `rish -c id` for uid 2000 |
| `start-daemon` | Start daemon Shizuku via adb (não substitui app; não instala rish) |
| `adb-connect` | Debug sem fio em 127.0.0.1: porta | pair | status | disconnect | wf |
| `wait` | Espera Shizuku responder via `rish -c true` (timeout 60s, env `ST_WAIT_TIMEOUT`) |
| `aliases` | Aliases opcionais `spm`/`sam` (plugin) |
| `uninstall` | Limpa launcher/dex/symlink, sem tinyurl |

## 5. Plugins de ponte (sempre existem; não dependem de ST_PLUGINS)

`sui`, `wireless`, `keepalive`, `usb-loopback`, `pm-install`, `start-daemon`, `aliases`, `adb-connect`.

ST_PLUGINS serve apenas para `plugins/consumers/` (MCP, Telegram, Lucky Patcher, game booster) — default off, sem vendor de binário alheio.

## 6. Recusas (veneno, nunca entra no núcleo)

- `tinyurl`, `curl … | bash`, `gist … | bash`
- DEX / `.so` commitados no git
- `chmod +w` / `+rwx` no DEX
- `releases/latest/download/rish` / fake releases (incluindo `install --source latest` que só aceita APK `*.apk`, nunca asset `rish`)
- `pkg install shizuku`
- `PKG` placeholder vivo
- Arquivo GPL do rish4termux (reimplementar o switch, não copiar)

## 7. Mapeamento de ABI (uname -m → arm ABI do APK)

`aarch64 → arm64-v8a`, `armv7l|armv8l → armeabi-v7a`, `x86_64 → x86_64`, `i686 → x86`. Sem match: skip `.so` + aviso.
