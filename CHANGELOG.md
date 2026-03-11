# Changelog

All notable changes to this configuration will be documented here.

## [Unreleased]

### ci
- Replace `nix fmt -- --check .` with `nix run nixpkgs#nixfmt-tree -- treefmt --ci .` in the format check job, adopting the official `nixfmt-tree`/`treefmt` toolchain with proper CI mode

### refactor
- Fix all `deadnix` warnings: remove unused lambda arguments (`pkgs` in `users/iago.nix`, `lib` in `apps/ollama.nix`)
- Fix all `statix` warnings:
  - W04 — replace `x = foo.x` assignments with `inherit (foo) x` in `hosts/hellplace.nix`, `apps/helium-browser.nix`, `apps/opencode-desktop.nix`
    - Note: `opencode = inputs.opencode.packages.${system}.opencode` → `inherit (inputs.opencode.packages.${system}) opencode` was flagged by statix in CI but not locally (version difference). Fixed with `statix fix` — when statix reports a W04 on an interpolated-path assignment, running `statix fix` resolves it correctly even if the manual `inherit` form isn't obvious.
  - W10 — replace empty patterns `{ ... }:` with `_:` in `users/iago.nix`, `desktop/ashell.nix`, `apps/onepassword.nix`
  - W19 — simplify `if foo ? bar then foo.bar else []` to `foo.bar or []` in `apps/opencode-desktop.nix`
  - W20 — merge repeated top-level keys into a single attribute set block in `desktop/kde.nix`, `hardware/hellplace.nix`, `users/iago.nix`

---

## [2025-03-10] — initial commit

- Initial NixOS flake configuration for host `hellplace`
- flake-parts + import-tree module architecture
- Hosts: hellplace (x86_64-linux, AMD GPU, impermanence)
- Desktop: niri (primary), KDE Plasma 6, GNOME (fallback)
- Gaming: Steam, GameMode, ROCm/OpenCL, VR
- Apps: Ghostty, Zed, 1Password, Helium Browser, Ollama, OpenCode Desktop
- CLI: Fish, tmux, dev-tools
- Secrets: agenix + agenix-rekey
- Persistence: impermanence on `/persist`
