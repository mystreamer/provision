{ ... }:

# KDE Plasma desktop with remote access over RDP.
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  # Plasma 6.8 is Wayland-only, so xrdp gets XFCE instead.
  services.xserver.desktopManager.xfce.enable = true;
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "xfce4-session";

  networking.firewall.allowedTCPPorts = [ 3389 ];
}
