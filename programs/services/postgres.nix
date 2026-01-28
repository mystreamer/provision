{ config, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/postgres 0755 root root -"
    "d /var/lib/postgres/data 0755 root root -"
  ];

  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers.postgres = {
    image = "postgres:latest";
    ports = [ 
      "0.0.0.0:5432:5432/tcp"
    ];
    volumes = [
      "/var/lib/postgres/data:/var/lib/postgresql/data:rw"
    ];
    environment = {
      POSTGRES_PASSWORD_FILE = "/run/secrets/postgresCreds";
      POSTGRES_DB = "postgres";
      PGDATA = "/var/lib/postgresql/data";
      TZ = "Europe/Zurich";
    };
    bindMounts = {
      "/run/secrets/postgresCreds" = {
        hostPath = config.age.secrets.postgresCreds.path;
        isReadOnly = true;
      };
    };
  };
}
