{ pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

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
      "bitwarden"
      # "ladybird"
    ];
    brews = [
      # "ghcup"
      # "llvm@17"
      # "jflex"
      # "tmux"
      "lazygit"
      "ncdu"
      "fastfetch"
    ];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.neovim
    # pkgs.neofetch
    # pkgs.lazygit
    # pkgs.jdk23
    # pkgs.ihp-new
    pkgs.direnv
    pkgs.devenv
  ] ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    orca
  ]);

  # Allow non-free software installs
  nixpkgs.config.allowUnfree = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.extra-substituters = [ "https://cache.numtide.com" ];
  nix.settings.extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;
  programs.zsh.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Set primary user
  system.primaryUser = "dylan";

  system.defaults.CustomUserPreferences = {
    # Custom stuff goes here
  };

  # Some system defaults
  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
  };

  # Running some custom commands / scripts
  system.activationScripts.postActivation.text = ''
    # Enable remoteLogin for SSH
    sudo systemsetup -setremotelogin on
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

  ### HOME MANAGER ###
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    verbose = true;
    users.dylan = {
      imports = [ ../../modules/home ];
      # this is internal compatibility configuration
      # for home-manager, don't change this!
      home.stateVersion = "23.05";

      home.packages = with pkgs; [];
    };
  };

  ### HOMEBREW (nix-homebrew) ###
  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = "dylan";

    # Take over an existing /opt/homebrew (keeps installed packages).
    # Only needed on the first activation of a machine that already has Homebrew.
    autoMigrate = true;

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
  };
}
