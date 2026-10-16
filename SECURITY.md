# Security

## Reporting vulnerabilities

Use the [GitHub Security Advisory](https://github.com/rianprei/shizuku-termux/security/advisories/new) to report security issues. Do not open public issues for vulnerabilities.

## Threat model

This repository is a bridge between Termux and Rikka's official Shizuku protocol. It is not an exploit, it does not bypass the Android sandbox and it does not root devices. `rish` inherits the UID of the Shizuku daemon (usually `uid=2000(shell)` via ADB or `uid=0` via root/Sui).

## Core security rules

- The Shizuku DEX must be `chmod 400` (non-writable) on Android 14+. A writable DEX makes `app_process` abort (A14).
- `RISH_APPLICATION_ID` must never remain as `"PKG"`. Use the real Termux package (`com.termux` or `com.termux.play`).
- Never download `releases/latest/download/rish` — that asset does not exist in Rikka's official release. `rish` is extracted from `assets/` inside the `moe.shizuku.privileged.api` APK.
- Do not use `tinyurl`, `curl | bash` or `gist | bash` to deliver code.

## Do not instruct exploits

This document does not describe, encourage or provide instructions for exploiting vulnerabilities, bypassing the sandbox, silent root or remote code execution.
