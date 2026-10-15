# Consumidores — apenas documentação

Os consumidores abaixo NÃO são dependência do núcleo shizuku-termux.
Eles aparecem apenas como documentação de referência. Se algum deles for
ativado, entra como plugin em `plugins/consumers/`, default off, sem vendor
de binário alheio.

| Consumidor | O que faz | Status no núcleo |
|------------|-----------|------------------|
| MCP (shizuku-mcp) | Expõe shell do Shizuku a LLM via MCP | Fora do núcleo; plugin opcional, default off |
| Telegram | Bot/bridge para comandos Shizuku | Fora do núcleo; plugin opcional, default off |
| Lucky Patcher | Modificação de apps | Fora do núcleo; não é dependência |
| game booster | Otimização de jogos via Shizuku | Fora do núcleo; não é dependência |
| celaya-solutions/android-claude-code-mcp-server | MCP + droid-sh para Claude Code | Fora do núcleo; não é dependência |
| SysopBP/Shizuku-TokenX | Fork multi-backend; DEX próprio; --root/--system/--shell | Fora do núcleo; não é dependência |
| ahmed-alnassif/AndroSH | Cliente Shizuku para Android | Fora do núcleo; não é dependência |
| Qutaiba-Khader/Shizuku-Tools | App Java Force Stop, não installer Termux | Fora do núcleo; não é dependência |
| light (quick-shell) | `light <minutos>` ajusta `screen_off_timeout` via `rish -c` | Consumidor: consome rish já instalado, não é ponte; fora do núcleo |

## Ideia (não consumidor, entra no núcleo como fonte)

| Repo | Ideia aproveitada | Onde |
|------|-------------------|------|
| crowforkotlin/quick-shell | `--source latest` + fallback `libshizuku.so --apk=`; `adb-connect` (debug sem fio em 127.0.0.1 sem tcpip) + `wf` (abre Wireless Debugging) | `src/lib/extract-apk.sh` (`st_download_official_apk`), `src/plugins/start-daemon.sh`, `src/plugins/adb-connect.sh` |
| auto-brevent (ideia) | `wait`: poll `rish -c true` até Shizuku responder | `src/lib/doctor.sh` (`st_wait`) |

## Regra
Nenhum consumidor entra no `src/` principal. Qualquer integração futura deve ser
um plugin isolado em `plugins/consumers/<nome>/`, controlado por `ST_PLUGINS`,
default off, e nunca inclui binário de terceiros (vendor proibido).
