# provision

This repo is intended for managing my flock of computers through Nix.

## macOS VM (devmac)

1. Ensure that CommandLineTools are installed.
2. Install nix (the non-determinate systems distribution)
3. Clone this repo and cd into it.
4. After cloning the first time on your machine, run:`sudo nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ".#devmac"`
If you have made changes to `flake.nix` and need a rebuild, use:
```
nix flake update
darwin-rebuild switch --flake .#devmac
```

## nixOS VM (ephem)

<!-- Basic instructions, see above.

`sudo nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake ".#ephem"` -->

Ephem is a VMWare Fusion VM. The same instructions as for **devnix** will apply though. Just the machine name has to be changed.

## nixOS VM (devnix)

### Initial steps

Devnix is a parallels guest VM. After starting the nixOS installer through an ISO found [here](https://nixos.org/download/#). Choose the version with the graphical installer.

<!-- Change keyboard mapping if necessary:

```
sudo loadkeys de_CH-latin1
``` -->

*Note*: This keymap is not the *macOS* flavour of the Swiss layout, but rather the classic Swiss layout, cf. [here](https://en.m.wikipedia.org/wiki/File:KB_Swiss.svg). the `#` can be accessed with `altGR + shift + 3`. Square brackets with `altGR + ü/¨` and curlies with `altGR + ä / $`

Then `cd /etc/nixos/configuration.nix`. Add this to the file:

```nix
nix = {
 package = pkgs.nix;
 settings.experimental-features = [ "nix-command" "flakes" ];
};
```

(*for vim as the editor just launch `nix-shell -p vim`*)

And then rebuild your nix with `sudo nixos-rebuild switch
`

<br>

0. Label the partitions: `sudo e2label /dev/sda2 nixos` and `sudo fatlabel /dev/sda1 BOOT`.
1. Get the repo onto the VM (Mutagen, see below).
2. Set `system.stateVersion` in `machines/devnix/default.nix` as in `/etc/nixos/configuration.nix`.
3. `nixos-rebuild build --flake ".#devnix"`
4. `sudo nixos-rebuild boot --flake ".#devnix"`, then reboot.

Use at least 64 GB of disk.

## Bare-metal provisioning

Use an nix-enabled machine to build the iso(-installer) image for the target-hardware.

A simple example how this is done can be found [here](https://coffeeaddict.dev/thinkdifferent/).

*Additional notes*:
+ If your nix-enabled machine (you're building from) does not have the same CPU-architecture, you may use github CI/CD to generate and download the image.
+ You might need to prepend `sudo` to most of the commands in the linked tutorial.
+ If you build the installer-image with flake enabled, you also must enable it when issuing the `nixos-install` command.
    - This goes like this: `sudo nixos-install --option experimental-features "nix-command flakes"`

## Submodules (quick-toc, yummie-recipe-manager)

The two service repos are git submodules under `repos/`, so they can be edited from inside this repo. The flake inputs still point at GitHub, so **push everything before you build**, otherwise machines will build different code.

Clone with submodules:
```
git clone --recurse-submodules git@github.com:mystreamer/provision.git
# or, in an existing clone
git submodule update --init --recursive
```

Submodules are checked out detached by default. Before editing one, switch it to its branch (`main` / `master`, set in `.gitmodules`):
```
git -C repos/quick-toc switch main
git -C repos/yummie-recipe-manager switch master
```

Push after editing a submodule (the submodule first, then this repo):
```
git push --recurse-submodules=on-demand
```

Pull everything:
```
git pull --recurse-submodules
```

Then pick up the new service revision in the flake: `nix flake update quick-toc yummie-recipe-manager`.

## Syncing with Mutagen

`mutagen.yml` mirrors this folder to `~/provision` on each host (one-way; two-way for `devmac`, which has Nix, so `flake.lock` updates come back).

```
mutagen project start
mutagen project terminate
```

- Don't edit files on a host; the next sync overwrites them.
- `~/provision` on a host must not contain a `.git`.

## Updating a host

- `nixos-rebuild build --flake .#<host>` first, then `test`, `switch` or `boot`.
- Container images are not updated by Nix: pull, then restart the service.
- `sudo nix-collect-garbage` frees disk.

## Adding your own service

Add the repo of the service to `flake.nix`.

Navigate to `programs/service/git-services.nix` and mkService it. Also make sure that you have the ports correctly set and each of the services has their own unique index (since that will be used to generate the NAT IP-addresses).

## Adding, using and removing secrets using agenix

Run the encryptor:
```
agenix -e secrets/myNewPassword.age
```

and paste your desired credentials inside the file, then save.

Add the new `.age` inside `secrets/secrets.nix`.


## Tipps

If github rate-limits you, generate a personal access token and set it with: `export NIX_CONFIG="access-tokens = github.com=..."`