# Security

## Reportando vulnerabilidades

Use o [GitHub Security Advisory](https://github.com/rianprei/shizuku-termux/security/advisories/new) para reportar problemas de segurança. Não abra issues públicas para vulnerabilidades.

## Modelo de ameaça

Este repositório é uma ponte entre Termux e o protocolo oficial Shizuku da Rikka. Ele não é um exploit, não contorna sandbox do Android e não roota dispositivos. O `rish` herda o UID do daemon Shizuku (geralmente `uid=2000(shell)` via ADB ou `uid=0` via root/Sui).

## Regras de segurança do núcleo

- O DEX do Shizuku deve ser `chmod 400` (não-gravável) em Android 14+. Um DEX gravável faz o `app_process` abortar (A14).
- `RISH_APPLICATION_ID` nunca deve ficar como `"PKG"`. Use o pacote real do Termux (`com.termux` ou `com.termux.play`).
- Nunca baixe `releases/latest/download/rish` — esse asset não existe no release oficial da Rikka. O `rish` é extraído do `assets/` dentro do APK `moe.shizuku.privileged.api`.
- Não use `tinyurl`, `curl | bash` ou `gist | bash` para entregar código.

## Não instrua exploit

Este documento não descreve, não encoraja e não fornece instruções para exploração de vulnerabilidades, bypass de sandbox, root silencioso ou execução remota de código.
