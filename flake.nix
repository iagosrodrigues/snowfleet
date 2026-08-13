{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";

    nur.url = "github:nix-community/NUR";
    niri.url = "github:sodiboo/niri-flake";
    ghostty.url = "github:ghostty-org/ghostty";
    ashell.url = "github:MalpenZibo/ashell";
    rust-overlay.url = "github:oxalica/rust-overlay";

    agenix.url = "github:ryantm/agenix";
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    impermanence.url = "github:nix-community/impermanence";
    # Chaotic-Nyx: binary cache + bleeding-edge packages (linux_cachyos, mesa_git, ...).
    # IMPORTANT: no `inputs.nixpkgs.follows` — pinning to nyx's own nixpkgs is
    # required for the binary cache to match (see nyx "cache troubleshooting").
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    comfyui-nix = {
      url = "github:utensils/comfyui-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Personal path inputs (not portable). Require sibling checkouts at the
    # absolute paths below. Consumed only by modules in the hellplace
    # `personal` profile (ai-jail, organice). See README "Personal flake".
    ai-jail = {
      url = "path:/home/iago/Projects/Personal/ai-jail";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    organice = {
      url = "path:/home/iago/Projects/Personal/organice";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake
      {
        inherit inputs;
      }
      {
        imports = [
          inputs.agenix-rekey.flakeModule
          (inputs.import-tree ./modules)
        ];
      };
}
