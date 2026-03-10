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
- **Desktop** -- GNOME (GDM) + [niri](https://github.com/YaLTeR/niri)
  compositor with [ashell](https://github.com/MalpenZibo/ashell) status bar
- **Gaming** -- Steam with Proton-GE, GameMode, WiVRn (wireless VR)
- **AI/ML** -- Ollama (ROCm), Open WebUI, ComfyUI
- **AMD GPU** -- ROCm runtime, LACT control, hardware video acceleration

## Architecture

```
flake.nix                         # Minimal entry point
modules/
├── flake/                        # Flake infrastructure (nixpkgs, devshell, home-manager base)
├── hosts/                        # Host definitions (nixosConfigurations)
│   └── hellplace.nix             # Main workstation
├── hardware/                     # Machine-specific hardware configs
├── users/                        # User definitions
├── system/                       # NixOS system modules
│   ├── agenix.nix                # Secret management (agenix + agenix-rekey)
│   ├── audio.nix                 # PipeWire (ALSA, PulseAudio, JACK)
│   ├── fonts.nix                 # System fonts
│   ├── io-schedulers.nix         # I/O scheduler tuning per device type
│   ├── lact.nix                  # AMD GPU control daemon
│   ├── networking.nix            # NetworkManager, locale, timezone
│   ├── nix.nix                   # Nix settings, caches, GC
│   ├── printing.nix              # CUPS
│   ├── tailscale.nix             # Tailscale VPN
│   └── virtualisation.nix        # Docker, libvirtd, virt-manager
├── desktop/                      # Desktop environments
│   ├── ashell.nix                # Ashell status bar config
│   ├── gnome.nix                 # GNOME + GDM + dconf + GTK theming
│   ├── kde.nix                   # KDE Plasma 6 + plasma-manager
│   └── niri.nix                  # Niri compositor + keybindings
├── gaming/                       # Gaming
│   ├── gamemode.nix              # Feral GameMode + kernel tuning
│   ├── steam.nix                 # Steam, Proton-GE, MangoHud
│   └── vr.nix                    # WiVRn wireless VR
├── apps/                         # Applications
│   ├── comfyui.nix               # ComfyUI (ROCm)
│   ├── ghostty.nix               # Ghostty terminal
│   ├── git.nix                   # Git aliases + delta + difftool
│   ├── helium-browser.nix        # Helium browser (AppImage)
│   ├── ollama.nix                # Ollama AI (Vulkan/ROCm)
│   ├── onepassword.nix           # 1Password + polkit
│   ├── opencode-desktop.nix      # OpenCode Desktop (Tauri)
│   ├── personal-git.nix          # Personal git identity (agenix + 1Password SSH signing)
│   ├── work-git.nix              # Work git identity (conditional include)
│   └── zed.nix                   # Zed editor
├── cli/                          # CLI tools
│   ├── dev-tools.nix             # direnv + mise
│   ├── shell.nix                 # Fish + Starship + zoxide
│   ├── ssh.nix                   # SSH via 1Password agent
│   └── tmux.nix                  # tmux
├── theming/                      # Theme modules
└── private/                      # No-op placeholder
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

```nix
# modules/hosts/hellplace.nix (simplified)
let
  nixos = config.flake.modules.nixos;
  hm = config.flake.modules.homeManager;
in {
  flake.nixosConfigurations.hellplace = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = (with nixos; [ audio fonts gnome niri steam ... ])
      ++ [{ home-manager.sharedModules = with hm; [ ghostty git zed ... ]; }];
  };
}
```

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
  flake.modules.nixos.gnome = { pkgs, ... }: { ... };
  flake.modules.homeManager.gnome = { lib, ... }: { ... };
}
```

## Commands

```bash
# Validate the flake (primary check)
nix flake check

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
4. Add the module key to the host's module list in `modules/hosts/hellplace.nix`
5. `nix flake check && nixos-rebuild build --flake .#hellplace`

## License

[MIT](LICENSE)
