{ ... }:

# KDE Plasma desktop with remote access over RDP.
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "startplasma-x11";

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
