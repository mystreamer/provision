{ ... }:
{
  imports = [
    ./photoprism.nix
    ./forgejo.nix
    # ./git-services.nix
    ./lyrion.nix
    ./postgres.nix
  ];

  virtualisation.oci-containers.backend = "docker";
}
