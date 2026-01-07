# Nix-based Multi-Machine Provisioning System

This repository manages a fleet of computers using NixOS and nix-darwin with flakes.

## Architecture Overview

**Three-tier machine hierarchy:**
- `flake.nix` - Central orchestrator defining all machines, inputs (nixpkgs, home-manager, nix-darwin, agenix), and shared configuration
- `machines/*/default.nix` - Per-machine NixOS/darwin configurations (devmac, devnix, ephem)
- `programs/*/default.nix` - Reusable program/service modules imported by machines

**Key design pattern:** Machine configs import program modules; program modules never import machine configs. This unidirectional dependency ensures modularity.

## Machine Types

- **devmac** (aarch64-darwin): macOS development machine using nix-darwin with Homebrew integration
- **devnix** (aarch64-linux): NixOS VM running in Parallels with GUI (GNOME) and Docker
- **ephem** (aarch64-linux): NixOS VM in VMWare Fusion, shares structure with devnix

## Critical Workflows

### Building/Rebuilding Systems

**First-time setup (devmac):**
```bash
sudo nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ".#devmac"
```

**Subsequent rebuilds:**
```bash
# macOS
darwin-rebuild switch --flake .#devmac

# NixOS (devnix/ephem)
sudo nixos-rebuild switch --flake ".#devnix"
```

Always run `nix flake update` after modifying `flake.nix` inputs.

### Rate Limiting Workaround
If GitHub rate-limits during builds:
```bash
export NIX_CONFIG="access-tokens = github.com=YOUR_PAT_TOKEN"
```

## Service Deployment Pattern

Services run as NixOS containers with NAT networking (defined in [programs/services/git-services.nix](programs/services/git-services.nix)).

**Adding a new service:**

1. Add service flake input to `flake.nix`:
   ```nix
   my-service.url = "git+ssh://git@github.com/user/my-service.git";
   ```

2. Pass to `serviceFlakes` in `flake.nix` outputs section:
   ```nix
   _module.args.serviceFlakes = {
     myservice = my-service;
   };
   ```

3. Configure in `programs/services/git-services.nix` using `mkService`:
   ```nix
   services = {
     myservice = {
       port = 8060;      # Exposed host port
       index = 5;        # Must be unique: generates 192.168.100.1X
     };
   };
   ```

4. Add to imports:
   ```nix
   imports = [
     (mkService "myservice" services.myservice serviceFlakes.myservice)
   ];
   ```

**Container networking:** Each service gets `192.168.100.${10 + index}` with NAT forwarding from host. External interface is `ens160`.

## Secrets Management

Uses agenix for encrypted secrets. All secrets in `secrets/` directory are encrypted with age using SSH keys.

**Secrets configuration:** [secrets/secrets.nix](secrets/secrets.nix) defines which keys can decrypt which secrets.

**Accessing secrets in services:** Secrets are bind-mounted into containers at `/run/secrets/<name>`:
```nix
bindMounts = {
  "/run/secrets/openai-api-key" = {
    hostPath = config.age.secrets.openai-api-key.path;
    isReadOnly = true;
  };
};
```

Environment variables use `_FILE` suffix convention: `OPENAI_API_KEY_FILE = "/run/secrets/openai-api-key"`.

## Program Modules

Located in `programs/`, these are imported into machine configs via home-manager or system configuration:

- **nvim** - Neovim with Coc, LSP, codecompanion (Anthropic), dracula theme, OSCYank for SSH clipboard
- **zsh** - Shell configuration with vi keybindings
- **tmux** - Terminal multiplexer config
- **services/** - Service definitions (Forgejo Docker container, git-services pattern, PhotoPrism)

**Import pattern in machine configs:**
```nix
home-manager.users.dylan = {
  imports = [
    ../../programs/nvim
    ../../programs/zsh
    ../../programs/tmux
  ];
};
```

## Conventions

- **User:** Always `dylan` (defined in machine configs)
- **State versions:** Set per-machine in `system.stateVersion` (devnix: "25.05", devmac: 6)
- **Editor:** `nvim` (set via `EDITOR` environment variable)
- **Git branch:** `main` (configured in home-manager git extraConfig)
- **Architecture:** All systems are `aarch64` (Apple Silicon/ARM64)
- **Keyboard layout (devnix):** Swiss German (`ch de_mac` for X11, `sg` for console)

## Directory Structure Rationale

- `machines/` - Hardware-specific and role-specific system configs
- `programs/` - Hardware-agnostic, reusable configurations
- `secrets/` - Encrypted configuration data (never commit unencrypted)
- `provision.sh` - Legacy bash provisioning (largely superseded by Nix)

## External Dependencies

- **Nix flakes:** Enable with `experimental-features = "nix-command flakes"`
- **Homebrew (macOS only):** Managed declaratively via nix-homebrew with taps for core/cask
- **Docker (devnix):** Enabled system-wide, user `dylan` in docker group
- **Home Manager:** Manages user-level configurations across all machines
