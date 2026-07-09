# Task 7 Report — P1 slim `users/iago.nix` + Helium to `pkgs/` (PR7)

## Status

**Complete**

## Summary

Slimmed the user module to identity + minimal home programs. Packages that previously lived only in `iago.nix` were either **moved into their dedicated HM modules** (modules that previously only declared persistence), **dropped as true system duplicates** (`_1password-cli`), or **collected into** `modules/cli/essentials.nix`. Session variables were relocated to desktop/gaming/shell with no hardcoded `/home/iago`. Helium’s derivation was extracted to `pkgs/helium-browser.nix` and registered on the nixpkgs overlay.

## Package inventory (from former `iago.nix` `home.packages`)

| Package | Destination |
|---------|-------------|
| `discord` | `modules/apps/discord.nix` (+ existing persistence) |
| `telegram-desktop` | `modules/apps/telegram.nix` |
| `vscode` | `modules/editors/vscode.nix` |
| `qbittorrent` | `modules/apps/qbittorrent.nix` |
| `code-cursor` | `modules/editors/code-cursor.nix` |
| `claude-desktop` | `modules/apps/claude-desktop.nix` |
| `llm-agents.{claude-code,codex,crush}`, `gemini-cli` | `modules/ai/ai-tools.nix` |
| `_1password-cli` | **Removed** — `programs._1password.enable` in `apps/onepassword.nix` |
| CLI/tooling + orphan GUI utils (eza, fd, jq, ripgrep, cargo/clang/nodejs/python3, btop+rocm, libreoffice, oversteer, proton-vpn, fuzzel, wl-clipboard, …) | `modules/cli/essentials.nix` |

**Confirmed before removal:** discord/telegram/vscode/qbittorrent/code-cursor/ai-tools/claude-desktop modules previously installed **only persistence** (no packages). Packages were added there first, then removed from the user.

## Session variables

| Variable(s) | Destination |
|-------------|-------------|
| `NIXOS_OZONE_WL`, `MOZ_ENABLE_WAYLAND`, `QT_QPA_PLATFORM`, `GDK_BACKEND`, `XCURSOR_*`, `GTK_IM_MODULE`, `QT_IM_MODULE` | `modules/desktop/kde.nix` (HM) |
| `STEAM_EXTRA_COMPAT_TOOLS_PATHS` | `modules/gaming/steam.nix` (HM) as `"${config.home.homeDirectory}/.steam/root/compatibilitytools.d"` |
| `EDITOR` (+ systemd user mirror) | `modules/cli/shell.nix` |

Eval check: `STEAM_EXTRA_COMPAT_TOOLS_PATHS` → `/home/iago/.steam/root/compatibilitytools.d` (via `homeDirectory`, not a hardcoded string in source).

## Helium extract

- **Created** `pkgs/helium-browser.nix` (callPackage body formerly embedded in the browser module).
- **Overlay** in `modules/flake/nixpkgs-config.nix`: `helium-browser = final.callPackage ../../pkgs/helium-browser.nix { };`
- **Slimmed** `modules/browsers/helium-browser.nix` to `pkgs.helium-browser` + 1Password native-messaging manifest + persistence (no long derivation).

## Membership

- Added `essentials` to `flake.profiles.hellplace.core.hm` in `modules/hosts/hellplace/profiles.nix`.

## `iago.nix` after

- NixOS user: username, groups, description, SSH key.
- HM user: `home-manager` / `mpv` / `fish` enable, `username` / `homeDirectory` / `stateVersion`, `fonts.fontconfig`.
- **No** `home.packages`, **no** session variables.

## Validation

| Check | Result |
|-------|--------|
| `nixfmt` on touched files | **Passed** |
| `nix flake check` | **Passed** (aarch64 omitted by default) |
| `nixos-rebuild build --flake .#hellplace` | **Passed** → `/nix/store/b0clq6chypz02nriyv12xscgwsyfmylq-nixos-system-hellplace-26.11.20260629.b5aa0fb` |
| Spot-check bins in per-user profile | discord, Telegram, code, cursor, qbittorrent, helium-browser, claude-desktop, gemini, eza, fd, rg, jq present; system `1password` present |

## Commits

- `refactor: slim user module and move helium package to pkgs/` (single commit covering user/essentials + helium)

## DoD checklist

- [x] `iago.nix` without packages duplicated against active modules
- [x] No `/home/iago` hardcoded in session vars (source)
- [x] `pkgs/helium-browser.nix` exists; module does not define long derivation
- [x] build OK

## Concerns / follow-ups

1. **`essentials` is a grab-bag:** includes non-CLI GUI tools (libreoffice, oversteer, proton-vpn, fuzzel, xwayland-satellite). Fine for “no dedicated module” leftovers; could later split desktop/gaming-specific items.
2. **`gemini-cli` under `ai-tools`:** grouped with other AI CLIs; gemini persistence dir was already in that module.
3. **`programs.fish.enable` still on user and in `shell`:** redundant double-enable; left as harmless personal preference on the user module.
4. **Helium NixOS module** still registers `environment.systemPackages = [ pkgs.helium-browser ]` but is **not** in hellplace profiles (HM-only). Unchanged membership behavior.
5. **`vscode` via `home.packages`** rather than `programs.vscode.enable` — matches prior install style; extensions remain unmanaged by HM.
6. **Closure delta:** not compared before/after; package set should be equivalent aside from dropping redundant `_1password-cli` from the user list (CLI still from system `_1password`).
