# Contributing

## Host tests

Run the full suite before opening a PR:

```bash
bash tests/run-all.sh
```

All tests must pass (exit 0). The tests run on the host, without a device and without a real adb network. Temporary files use `${TMPDIR:-/tmp}`, so on Termux set `TMPDIR="$PREFIX/tmp"` (or any writable directory) if `/tmp` is not writable.

## Pull request rules

- No `.dex`, `.so`, `.apk` or `.deb` in git.
- No `tinyurl`, `curl | bash` or `gist | bash` in the core.
- No `chmod +w` / `+rwx` on the DEX.
- No live `PKG` placeholder in the generated launcher.
- No copied GPL file from rish4termux; reimplement, do not copy.
- Commit messages in the Conventional Commits format (e.g. `feat:`, `fix:`, `docs:`).
- Do not commit into the parent vault (`tabs-agent-os`). This repository is standalone.

## Secret check

Before submitting a PR, confirm that there are no API keys, tokens, passwords or private keys in the tracked files.
