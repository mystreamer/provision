{ ... }:

# Home-manager config shared by every host (macOS and NixOS).
# home.stateVersion is deliberately left to each host.
{
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "mystreamer";
      user.email = "me@dylanmassey.ch";
      init.defaultBranch = "main";
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
