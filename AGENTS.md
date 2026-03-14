# AGENTS.md — NixOS Dotfiles (flake-parts + import-tree)

This file provides guidance for AI coding agents working in this repository.

## Repository Overview

A NixOS configuration using **flake-parts** for modular flake structure and **import-tree** for automatic module discovery.

How loading works — two distinct steps:

1. **`import-tree` auto-evaluates** every `.nix` file under `modules/` as a flake-parts module, which registers each file's `flake.modules.nixos.*` / `flake.modules.homeManager.*` entries into the flake-parts config. New files must be `git add`-ed to be seen.
2. **Hosts explicitly select** which registered modules to actually include in the NixOS system build. A module that is registered but not listed in the host's module list has **no effect** on the built system.

## Build / Check Commands

```bash
# Validate the flake (syntax + evaluation — runs this frequently)
nix flake check

# Build without switching (safe, no system changes)
nixos-rebuild build --flake .#hellplace

# Apply changes to the running system
sudo nixos-rebuild switch --flake .#hellplace

# Test temporarily (reverts on reboot)
sudo nixos-rebuild test --flake .#hellplace

# Evaluate a specific config attribute (fast, targeted check)
nix eval .#nixosConfigurations.hellplace.config.system.build.toplevel

# Format all Nix files
nix fmt

# Enter dev shell (provides: nixfmt, deadnix, statix, nil)
nix develop

# Inside dev shell — lint and dead code checks
statix check .
deadnix .

# Update all flake inputs
nix flake update

# Update a single input
nix flake lock --update-input nixpkgs
```

There are no unit tests, no Makefile, and no justfile. `nix flake check` is the primary validation tool.

Fish shell aliases (available on the system, not in dev shell):
```
nrs   # sudo nixos-rebuild switch --flake .#(hostname) | nix-output-monitor
nrt   # sudo nixos-rebuild test   --flake .#(hostname) | nix-output-monitor
```

## Architecture

```
flake.nix                         # Minimal entry point (~35 lines)
modules/
├── flake/                        # Flake infrastructure (nixpkgs, devshell, home-manager base)
├── hosts/                        # Host definitions (nixosConfigurations outputs)
├── hardware/                     # Machine-specific hardware configs
├── users/                        # User definitions
├── system/                       # NixOS system modules (audio, fonts, networking, etc.)
├── desktop/                      # Desktop environments (kde, niri, gnome, ashell)
├── gaming/                       # Gaming modules (steam, gamemode, graphics, vr)
├── apps/                         # Application modules (browsers, ghostty, git, etc.)
├── cli/                          # CLI tool modules (shell, tmux, dev-tools)
├── theming/                      # Theme modules
└── private/                      # Legacy no-op module (kept for compatibility)
secrets/                          # agenix source secrets + rekeyed host outputs
disko/                            # Declarative disk partitioning configs
```

## Module Patterns

### Every file is a flake-parts module

All files must be functions at the top level:

```nix
# Minimal — no inputs needed
_: {
  flake.modules.nixos.audio = {
    services.pipewire.enable = true;
  };
}

# With pkgs
_: {
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts.packages = with pkgs; [ noto-fonts ];
    };
}

# With flake inputs
{ inputs, ... }: {
  flake.modules.nixos.sops = {
    imports = [ inputs.sops-nix.nixosModules.sops ];
  };
}
```

### Home-Manager modules

The value of `flake.modules.homeManager.*` is itself a module function:

```nix
_: {
  flake.modules.homeManager.ghostty = _: {
    programs.ghostty = {
      enable = true;
    };
  };
}
```

### Combined NixOS + Home-Manager in one file

When a concern spans both system and user level, define both in the same file:

```nix
{ inputs, ... }: {
  flake.modules.nixos.kde =
    { pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;
    };

  flake.modules.homeManager.kde =
    { ... }:
    {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];
      programs.plasma.enable = true;
    };
}
```

### One file can export multiple modules

```nix
# desktop/niri.nix exports three separate modules:
flake.modules.nixos.niri = ...;
flake.modules.homeManager.niri = ...;
flake.modules.homeManager.niri-config = ...;
```

### Host definition pattern

```nix
{ inputs, config, ... }:
let
  nixos = config.flake.modules.nixos;
  hm = config.flake.modules.homeManager;

  nixosModules = with nixos; [ audio fonts networking kde ] ++ [
    nixos.hellplace-hardware
    inputs.disko.nixosModules.disko
    { networking.hostName = "hellplace"; }  # inline anonymous module
  ];

  hmModules = with hm; [ browsers ghostty kde ] ++ [
    { home.persistence."/persist".directories = [ "Downloads" ]; }
  ];
in {
  flake.nixosConfigurations.hellplace = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = nixosModules ++ [{ home-manager.sharedModules = hmModules; }];
  };
}
```

Hosts use **selective composition** — explicitly listing which modules to include — not `builtins.attrValues` of all modules.

## Naming Conventions

- **File names**: `kebab-case.nix` (e.g., `io-schedulers.nix`, `dev-tools.nix`)
- **Module keys**: `kebab-case` (e.g., `gaming-graphics`, `nix-settings`, `mouse-config`)
- **Module key ≠ filename**: `system/nix.nix` exports `flake.modules.nixos.nix-settings`
- **Hardware modules**: named `<hostname>-hardware` (e.g., `hellplace-hardware`)
- **No custom options**: This codebase does not use `mkOption` / `options = {}` blocks — all configuration is plain attribute assignment against existing NixOS/HM options

## Code Style

- **Formatter**: `nixfmt` (run via `nix fmt`). Always format before committing.
- **Indentation**: 2 spaces. No tabs.
- **Argument style**: Prefer `_:` when args are unused. Destructure only what is needed:
  ```nix
  { pkgs, ... }:    # good — only pkgs needed
  { pkgs, lib, config, inputs, ... }:  # avoid — don't list unused args
  ```
- **`with` scope**: Use `with pkgs;` for package lists, `with nixos;` / `with hm;` in host module lists. Avoid `with` in deeply nested expressions.
- **List formatting**: One item per line for lists longer than 3 items.
- **Comments**: Use `#` comments to group related config. No `/* */` block comments in module bodies.
- **No `mkIf` for module activation**: Module inclusion is controlled at the host level (via the module list), not inside the module itself with `mkIf config.local.*`.
- **`lib.mkMerge` / `lib.mkDefault`**: Use sparingly; prefer flat, direct attribute assignment.

## impermanence / Persistence

- NixOS system persistence: `environment.persistence."/persist".directories`
- Home-Manager persistence: `home.persistence."/persist".directories`
- Both support multiple declarations — they are merged (list concatenation), not overwritten.
- Module-specific persistence entries belong in the module file (e.g., KDE persistence dirs in `desktop/kde.nix`). Host-level persistence in the host file covers general user data.

## Secrets (agenix + agenix-rekey)

- This repo uses `agenix` + `agenix-rekey` (not private flake) for sensitive values.
- Source secrets live in `secrets/*.age` encrypted to the master identity (YubiKey).
- Host-consumable artifacts are generated into `secrets/rekeyed/<hostname>/` via rekey.
- Rekey config is centralized in `modules/system/agenix.nix`.

### Add a new secret

1. Create encrypted source file:
   ```bash
   nix develop
   agenix edit secrets/<name>.age
   ```
2. Wire it in NixOS/host module:
   ```nix
   age.secrets.<name>.rekeyFile = ../../secrets/<name>.age;
   ```
   Then consume with `config.age.secrets.<name>.path`.
3. Rekey for hosts:
   ```bash
   nix develop -c agenix rekey -a
   ```
4. Ensure generated file exists under `secrets/rekeyed/<hostname>/` and `git add` both source and rekeyed files.
5. Validate:
   ```bash
   nix flake check
   nixos-rebuild build --flake .#hellplace
   ```

### Important notes for agents

- New module files and new secret files must be tracked (`git add`) before evaluation/rekey workflows can see them.
- Do not commit plaintext secrets, hashes, tokens, or private keys in `.nix` files.
- Prefer storing personal Git identity/account values in agenix-backed files (e.g., include file under `/run/agenix/...`) instead of inline config.

## General Guidance for Agents

- **When in doubt, search first**: Before assuming a package name, version, tag, or API, verify it using a web search (e.g. on ollama.com, nixpkgs, GitHub). Confidently wrong answers are worse than asking. This has caused real issues in this repo — e.g. asserting `qwen3.5` didn't exist when it did.

## Common Pitfalls

- **New file not picked up**: Run `git add <file>` — flake evaluation only sees git-tracked files.
- **"attribute X missing"**: Verify the module exports to `flake.modules.nixos.<key>` or `flake.modules.homeManager.<key>` **and** the host explicitly lists that key in its module list.
- **"infinite recursion"**: Check for circular references between modules.
- **xorg deprecation warnings**: Any module referencing `pkgs.xorg.libX*` at evaluation time triggers these. Use top-level package names (e.g., `libx11`) instead of `xorg.libX11`.
- **Don't use `pkgs.xorg.*`**: The xorg attribute set is deprecated in nixpkgs-unstable. Reference X11 libs directly (e.g., `pkgs.libx11`, `pkgs.libxrandr`).
