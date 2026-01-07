{ config, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/lyrion 0755 root root -"
    "d /var/lib/lyrion/config 0755 root root -"
    "d /var/lib/lyrion/music 0755 root root -"
    "d /var/lib/lyrion/playlists 0755 root root -"
  ];

  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers.lyrion = {
    image = "lmscommunity/lyrionmusicserver:latest";
    ports = [ "0.0.0.0:9000:9000" ];
    volumes = [
      "/var/lib/lyrion/config:/config"
      "/var/lib/lyrion/music:/music"
      "/var/lib/lyrion/playlists:/playlists"
    ];
  };
}
