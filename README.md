provision

--------

This repo is intended for managing my flock of computers through Nix.

## macOS VM

1. Ensure that CommandLineTools are installed.
2. Install nix (the non-determinate systems distribution)
3. Clone this repo and cd into it.
4. After cloning the first time on your machine, run:`nix run nix-darwin -- switch --flake .#simple`
If you have made changes to `flake.nix` and need a rebuild, use:
```
nix flake update
darwin-rebuild switch --flake .#simple
```
