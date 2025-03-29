{
  description = "Dylan's macOS Developer VM Setup";

  inputs = {
    # The base
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Responsible for management of dotfile type things.
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, nix-homebrew, homebrew-core, homebrew-cask }:
  let
    configuration = { pkgs, ... }: {
      # Declare which user will be running nix
      users.users.dylan = {
	name = "dylan";
	home = "/Users/dylan";
      };

      homebrew = {
	  enable = true;
	  onActivation.autoUpdate = true;
	  onActivation.upgrade = true;
	  # updates homebrew packages on activation,
	  # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
	  casks = [
	    # "alfred"
	    "visual-studio-code"
	 ];
          brews = [
	    "ghcup"
         ];
      };

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
	  pkgs.neofetch
	  pkgs.lazygit
	  pkgs.jdk23
        ];

      # Allow non-free software installs
      nixpkgs.config.allowUnfree = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.defaults.CustomUserPreferences = {
	# Custom stuff goes here
      };

      # Some system defaults
      system.defaults = {
	finder.AppleShowAllExtensions = true;
	finder.AppleShowAllFiles = true;
      };

      # Running some custom commands / scripts
      system.activationScripts.postUserActivation.text = ''
	    # Enable remoteLogin for SSH
            sudo systemsetup -setremotelogin on
	    # Following line should allow us to avoid a logout/login cycle
	    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';

    };
    homeconfig = {pkgs, ...}: {
		# this is internal compatibility configuration 
		# for home-manager, don't change this!
		home.stateVersion = "23.05";
		# Let home-manager install and manage itself.
		programs.home-manager.enable = true;

		programs.git = {
		      enable = true;
		      userName = "mystreamer";
		      userEmail = "me@dylanmassey.ch";
		      extraConfig = {
			init.defaultBranch = "main";
		      };
		    };

		home.packages = with pkgs; [];

		home.sessionVariables = {
		EDITOR = "vim";
		};
    };
    brewconfig = {
	    # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "dylan";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };

            # Optional: Enable fully-declarative tap management
            #
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [ configuration 
	   home-manager.darwinModules.home-manager  {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.verbose = true;
                home-manager.users.dylan = homeconfig;
            }
	   nix-homebrew.darwinModules.nix-homebrew {
	        nix-homebrew = brewconfig;
	    }
	];
    };
  };
}
