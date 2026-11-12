{
  description = "mstrmrs macOS Developer VM Setup";

  inputs = {
    # The base
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  
    # Responsible for management of dotfile type things.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # agenix
    agenix.url = "github:ryantm/agenix";

    # Coding agents (claude-code, orca, ...). Deliberately no `follows nixpkgs`:
    # the binary cache only hits for the nixpkgs revision it was built with.
    llm-agents.url = "github:numtide/llm-agents.nix";

    # VS Code Server support on NixOS
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # Nix darwin
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # Homebrew (only responsible for managing homebrew itself, not the stuff it installs)
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # Some declarative taps :)
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # personals
    quick-toc = {
      url = "github:mystreamer/quick-toc";
      # or for specific branch: url = "github:mystreamer/quick-toc/main";
    };
    yummie-recipe-manager = {
      url = "git+ssh://git@github.com/mystreamer/yummie-recipe-manager.git";
    };

  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, agenix, quick-toc, yummie-recipe-manager, ... }:
  let
    lib = nixpkgs.lib;
    # lib = nixpkgs.lib.extend (self: super: {
    #     my = import ./lib { inherit inputs; lib = self; };
    # });

    processConfigurations = lib.mapAttrs (n: v: v n);
    darwinSystem = system: extraModules: hostName:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = extraModules;
      };
    nixosSystem = system: extraModules: hostName:
      nixpkgs.lib.nixosSystem rec {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          {
              # Pass the flake as a special arg
              _module.args.serviceFlakes = {
                quicktoc = quick-toc;
                yummie = yummie-recipe-manager;
          };
          }
          { environment.systemPackages = [ agenix.packages.${system}.default ];}
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          ({ config, ... }: lib.mkMerge [{
              networking.hostName = hostName;
            }])
        ] ++ extraModules;
      };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
  darwinConfigurations = processConfigurations { 
      devmac = darwinSystem "aarch64-darwin" [ ./machines/devmac/default.nix ];
    };
  nixosConfigurations = processConfigurations {
      devnix = nixosSystem "aarch64-linux" [ ./machines/devnix/default.nix ];
      ephem  = nixosSystem "aarch64-linux" [ ./machines/ephem/default.nix ];
    };
  };
}
