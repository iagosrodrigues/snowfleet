# snowfleet

NixOS configuration for my personal workstation, built with
[flake-parts](https://flake.parts/) and
[import-tree](https://github.com/vic/import-tree) for automatic module
discovery.

## Highlights

- **Impermanence** -- tmpfs root (`/`) with selective persistence on encrypted
  btrfs via [disko](https://github.com/nix-community/disko)
- **LUKS + FIDO2** -- full-disk encryption unlocked by YubiKey
- **Secrets** -- [agenix](https://github.com/ryantm/agenix) +
  [agenix-rekey](https://github.com/oddlama/agenix-rekey) (YubiKey master
  identity)
- **Desktop** -- KDE Plasma 6 (SDDM) with plasma-manager; experimental DE
  modules (GNOME, niri, ashell) live under `archive/desktop/`
- **Gaming** -- Steam with Proton-GE, GameMode, WiVRn (wireless VR)
- **AI/ML** -- Ollama (ROCm), Open WebUI, ComfyUI
- **AMD GPU** -- ROCm runtime, LACT control, hardware video acceleration

## Architecture

```
flake.nix                         # Minimal entry point
modules/
├── flake/                        # Flake infrastructure (nixpkgs, devshell, home-manager base)
├── hosts/                        # Host definitions (nixosConfigurations)
│   └── hellplace/                # Main workstation
│       ├── default.nix           # Composes profiles + host-specific stack
│       ├── profiles.nix          # Named module profiles (core, desktop-kde, …)
│       └── secrets.nix           # Host age secrets
├── hardware/                     # Machine-specific hardware configs
├── users/                        # User definitions
├── system/                       # NixOS system modules
│   ├── agenix.nix                # Secret management (agenix + agenix-rekey)
│   ├── audio.nix                 # PipeWire (ALSA, PulseAudio, JACK)
│   ├── fonts.nix                 # System fonts
│   ├── io-schedulers.nix         # I/O scheduler tuning per device type
│   ├── lact.nix                  # AMD GPU control daemon
│   ├── networking.nix            # NetworkManager, locale, timezone
│   ├── nix-settings.nix          # Nix settings, caches, GC
│   ├── printing.nix              # CUPS
│   ├── tailscale.nix             # Tailscale VPN
│   └── virtualisation.nix        # Docker, libvirtd, virt-manager
├── desktop/                      # Desktop environments (active on host)
│   └── kde.nix                   # KDE Plasma 6 + plasma-manager
├── gaming/                       # Gaming
│   ├── gamemode.nix              # Feral GameMode + kernel tuning
│   ├── steam.nix                 # Steam, Proton-GE, MangoHud
│   └── vr.nix                    # WiVRn wireless VR
├── apps/                         # Application modules (browsers, editors, AI tools, git, …)
└── cli/                          # CLI tools
    ├── dev-tools.nix             # direnv + mise
    ├── shell.nix                 # Fish + Starship + zoxide
    ├── ssh.nix                   # SSH via 1Password agent
    ├── tmux.nix                  # tmux
    └── zellij.nix                # Zellij
archive/                          # Unused/experimental modules outside import-tree
├── desktop/                      # niri, gnome, ashell
├── apps/                         # nixvim
└── pkgs/                         # zed-editor (custom FHS wrapper)
secrets/                          # Encrypted secrets (agenix .age files)
disko/                            # Declarative disk partitioning
```

## How it works

### Two-step module loading

1. **`import-tree` discovers** every `.nix` file under `modules/` and registers
   it as a flake-parts module. Each file exports to
   `flake.modules.nixos.<key>` and/or `flake.modules.homeManager.<key>`.

2. **Hosts selectively compose** which registered modules to include. A module
   that is registered but not listed in a host's module list has no effect on
   the built system.

### Host composes profiles

Hellplace does not list every module inline. Named profiles live in
`modules/hosts/hellplace/profiles.nix` as `flake.profiles.hellplace.*` (NixOS
+ Home-Manager lists per bundle). The host concatenates those lists and adds
host-only pieces (hardware, secrets, disko, impermanence, hostname).

Profiles today: `core`, `desktop-kde`, `gaming`, `ai`, `apps-daily`.

```nix
# modules/hosts/hellplace/default.nix (simplified)
let
  inherit (config.flake.modules) nixos;
  profiles = config.flake.profiles.hellplace;

  sharedNixosModules =
    profiles.core.nixos
    ++ profiles.desktop-kde.nixos
    ++ profiles.gaming.nixos
    ++ profiles.ai.nixos
    ++ profiles.apps-daily.nixos;
in {
  flake.nixosConfigurations.hellplace = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules =
      sharedNixosModules
      ++ [ nixos.hellplace-hardware nixos.hellplace-secrets /* disko, … */ ]
      ++ [{ home-manager.sharedModules = /* same pattern for .hm lists */; }];
  };
}
```

Every `.nix` under `modules/` is a flake-parts module (import-tree). Profile
data is therefore exposed via `flake.profiles.*`, not as a pure function file
or raw NixOS module.

### Module patterns

Every file is a flake-parts module. The outer function receives flake-level
args, the inner function receives NixOS/HM module args:

```nix
# NixOS module
_: {
  flake.modules.nixos.audio = {
    services.pipewire.enable = true;
  };
}

# Home-Manager module
_: {
  flake.modules.homeManager.ghostty = _: {
    programs.ghostty.enable = true;
  };
}

# Combined (NixOS + HM in one file)
{ inputs, ... }: {
  flake.modules.nixos.kde = { pkgs, ... }: { ... };
  flake.modules.homeManager.kde = { lib, ... }: { ... };
}
```

## Commands

```bash
# Validate the flake (primary check)
nix flake check

# Run the same checks as GitHub Actions locally
./scripts/check-ci

# Build without switching (safe, no system changes)
nixos-rebuild build --flake .#hellplace

# Apply changes
sudo nixos-rebuild switch --flake .#hellplace

# Test temporarily (reverts on reboot)
sudo nixos-rebuild test --flake .#hellplace

# Format all Nix files
nix fmt

# Enter dev shell (nixfmt, deadnix, statix, nil, agenix)
nix develop

# Lint
nix develop -c statix check .
nix develop -c deadnix .

# Update all flake inputs
nix flake update
```

To enable the versioned Git hooks in this repository:

```bash
git config core.hooksPath .githooks
```

With that in place, `pre-commit` formats staged `.nix` files and `pre-push`
runs the same checks as `.github/workflows/check.yml`.

## Secrets management

Secrets are encrypted with [agenix](https://github.com/ryantm/agenix) +
[agenix-rekey](https://github.com/oddlama/agenix-rekey). The master identity
is a YubiKey; host keys are ed25519.

```bash
# Edit/create a secret
nix develop -c agenix edit secrets/<name>.age

# Rekey for all hosts after adding a new secret
nix develop -c agenix rekey -a
```

Wire it in a module:

```nix
age.secrets.<name>.rekeyFile = ../../secrets/<name>.age;
# Then use: config.age.secrets.<name>.path
```

See `secrets/README.md` for the full workflow.

## Adding a new module

1. Create a file under the appropriate directory (e.g. `modules/system/bluetooth.nix`)
2. Export to `flake.modules.nixos.<key>` and/or `flake.modules.homeManager.<key>`
3. `git add` the file (flake evaluation only sees tracked files)
4. Add the module key to the appropriate profile in
   `modules/hosts/hellplace/profiles.nix` (or to the host-only stack in
   `modules/hosts/hellplace/default.nix` for machine-specific pieces)
5. `nix flake check && nixos-rebuild build --flake .#hellplace`

## License

[MIT](LICENSE)
