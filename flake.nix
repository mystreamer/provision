{
  "nodes": {
    "nix-darwin": {
      "inputs": {
        "nixpkgs": [
          "nixpkgs"
        ]
      },
      "locked": {
        "lastModified": 1743125241,
        "narHash": "sha256-TA/xYqZbBwCCprXf8ABORDsjJy0Idw6OdQNqYQhgKCM=",
        "owner": "LnL7",
        "repo": "nix-darwin",
        "rev": "75f8e4dbc553d3052f917e66ee874f69d49c9981",
        "type": "github"
      },
      "original": {
        "owner": "LnL7",
        "ref": "master",
        "repo": "nix-darwin",
        "type": "github"
      }
    },
    "nixpkgs": {
      "locked": {
        "lastModified": 1743076231,
        "narHash": "sha256-yQugdVfi316qUfqzN8JMaA2vixl+45GxNm4oUfXlbgw=",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "6c5963357f3c1c840201eda129a99d455074db04",
        "type": "github"
      },
      "original": {
        "owner": "NixOS",
        "ref": "nixpkgs-unstable",
        "repo": "nixpkgs",
        "type": "github"
      }
    },
    "root": {
      "inputs": {
        "nix-darwin": "nix-darwin",
        "nixpkgs": "nixpkgs"
      }
    }
  },
  "root": "root",
  "version": 7
}
