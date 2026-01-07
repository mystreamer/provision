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
    ports = [ 
      "0.0.0.0:9000:9000/tcp"
      "0.0.0.0:9090:9090/tcp"
      "0.0.0.0:3483:3483/tcp"
      "0.0.0.0:3483:3483/udp"
    ];
    volumes = [
      "/var/lib/lyrion/config:/config:rw"
      "/var/lib/lyrion/music:/music:ro"
      "/var/lib/lyrion/playlists:/playlist:rw"
      "/etc/localtime:/etc/localtime:ro"
    ];
  };
}
