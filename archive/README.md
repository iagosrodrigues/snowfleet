# archive/

These files are **not** loaded by `import-tree`. `flake.nix` only imports
`./modules`, so nothing under `archive/` is registered as a flake-parts module
or evaluated as part of the hellplace system.

## Why this exists

Keep experimental / unused modules and dead packages in git history with a
clear home, without polluting the hot path under `modules/`. Hellplace only
selects modules that live under `modules/` and are listed in
`modules/hosts/hellplace.nix`.

## How to reactivate

1. Move the file back under the appropriate `modules/` (or `pkgs/`) path:
   ```bash
   git mv archive/desktop/niri.nix modules/desktop/
   ```
2. `git add` the restored path (flake evaluation only sees tracked files).
3. Wire it in:
   - **Modules:** add the export key to the host's NixOS/HM module list in
     `modules/hosts/hellplace.nix` (or a future profile).
   - **Packages:** re-enable the overlay line in
     `modules/flake/nixpkgs-config.nix` if needed.
4. Validate:
   ```bash
   nix flake check
   nixos-rebuild build --flake .#hellplace
   ```

## Contents

| Path | Why archived |
|------|----------------|
| `desktop/niri.nix` | Niri compositor + wrapper package; not selected on hellplace (KDE is active). |
| `desktop/gnome.nix` | GNOME DE fallback; not selected on hellplace. |
| `desktop/ashell.nix` | Ashell status bar (niri companion); not selected on hellplace. |
| `apps/nixvim.nix` | nixvim HM config; not listed on hellplace. |
| `pkgs/zed-editor.nix` | Custom FHS-wrapped Zed package; overlay line was already commented out (`modules/apps/zed.nix` uses stock `programs.zed-editor`). |

## Not archived (intentionally)

- **`gamemode`** — activated on hellplace in Task 3 (pairs with Steam/VR), not experimental.
- **`claude-desktop` module** — still on the hellplace HM path (persistence for `.config/Claude`) and package via `pkgs/claude-desktop.nix` + overlay.
- **Flake inputs** `niri` / `ashell` — still declared in `flake.nix` (niri overlay remains in nixpkgs-config); pruning inputs is out of scope for this archive pass.
