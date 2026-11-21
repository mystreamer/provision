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

0. Label the partitions once, so `machines/devnix/hardware-configuration.nix` (which addresses disks by label, not UUID) works unchanged: `sudo e2label /dev/sda2 nixos` and `sudo fatlabel /dev/sda1 BOOT`. Adjust the device names if `lsblk` shows others.
1. Get the repo onto the VM, either by Mutagen (see below) or `nix-shell -p git` and a clone of this repo.
2. Set `system.stateVersion` in `machines/devnix/default.nix` to the version in `/etc/nixos/configuration.nix`.
3. Build first: `nixos-rebuild build --flake ".#devnix"`
4. Then `sudo nixos-rebuild boot --flake ".#devnix"` and reboot. (`boot` instead of `switch`, because a nixpkgs jump can change critical components such as the D-Bus implementation, which NixOS refuses to switch to live.)

The VM needs at least 64 GB of disk. If a build fills it, `sudo nix-collect-garbage` frees what no generation uses.

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

`mutagen.yml` mirrors this folder to `~/provision` on each host: one-way for the NixOS hosts, two-way for `devmac`, so a `nix flake update` run there (this Mac has no Nix) comes back as a changed `flake.lock`.

```
mutagen project start       # create the sessions
mutagen project terminate   # remove them
```

- Do not edit files on a one-way host. The next sync overwrites them.
- A host's `~/provision` must not have its own `.git`. Nix reads a git checkout as "tracked files only" and would ignore the synced, untracked files. Move an old clone out of the folder first (for example to `~/provision-old.git`), never rename it inside, because the mirror deletes extra files.
- The ignore list covers `.git` (also the file a git worktree uses), `repos/`, `result`, `.direnv` and `mutagen.yml` itself.
- Sessions are named per host. A second project with the same session names cannot run next to a running one.

## Updating a host

- Build before you switch: `nixos-rebuild build --flake .#<host>`, then `test`, `switch` or `boot`.
- Nix does not update container images. Images are pinned in `programs/services/` (Postgres to its major version, Forgejo to `13`); `:latest` ones only change when you pull and restart them. A new Postgres major needs a dump and restore.
- The store grows with every generation and failed build. `sudo nix-collect-garbage` reclaims it.

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