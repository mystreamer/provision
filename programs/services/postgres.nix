{ config, ... }:

{
  systemd.tmpfiles.rules = [
    "d /var/lib/postgres 0755 root root -"
    "d /var/lib/postgres/data 0755 root root -"
  ];

  virtualisation.oci-containers.containers.postgres = {
    # Pinned to the major version of the existing data directory.
    # A new major needs a dump and restore; do not use :latest.
    image = "postgres:18";
    ports = [ 
      "0.0.0.0:5432:5432/tcp"
    ];
    volumes = [
      "/var/lib/postgres/data:/var/lib/postgresql/data:rw"
      "${config.age.secrets.postgresCreds.path}:/run/secrets/postgresCreds:ro"
    ];
    environment = {
      POSTGRES_PASSWORD_FILE = "/run/secrets/postgresCreds";
      POSTGRES_DB = "postgres";
      PGDATA = "/var/lib/postgresql/data";
      TZ = "Europe/Zurich";
    };
  };
}
