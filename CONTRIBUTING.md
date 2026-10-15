# Contributing

## Testes host

Execute a suíte completa antes de abrir um PR:

```bash
bash tests/test-*.sh
```

Todos os testes devem passar (exit 0). Os testes rodam no host, sem device e sem rede real para adb.

## Regras de pull request

- Nenhum `.dex`, `.so`, `.apk` ou `.deb` no git.
- Nenhum `tinyurl`, `curl | bash` ou `gist | bash` no núcleo.
- Nenhum `chmod +w` / `+rwx` no DEX.
- Nenhum `PKG` placeholder vivo no launcher gerado.
- Nenhum arquivo GPL do rish4termux copiado; reimplementar, não copiar.
- Mensagens de commit no formato Conventional Commits (ex: `feat:`, `fix:`, `docs:`).
- Não commite no vault pai (`tabs-agent-os`). Este repositório é autônomo.

## Verificação de segredos

Antes de enviar um PR, confirme que não há chaves de API, tokens, senhas ou private keys nos arquivos rastreados.
