{
  description = "Dylan's macOS Developer VM Setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # Declare which user will be running nix
      users.users.dylan = {
	name = "dylan";
	home = "/Users/dylan";
      };

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
	  pkgs.neofetch
	  pkgs.lazygit
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
	];
    };
  };
}
