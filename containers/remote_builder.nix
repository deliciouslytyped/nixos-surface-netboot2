#! /usr/bin/env nix-shell
#! nix-shell -i "bash -c '$(nix-build $EXTRA_NIX_ARGS -A config.shebang.fast --no-out-link \"$1\") \"$@\"' --" -p ""

#TODO make nixos-container actually confirm that the restart has changed the system, idk why it doesnt osmetimes...
#NOTE (see also note #??) the host is respnsible for checking trustedusers and builds etc
let
  container_name = "remoteb";
  master-netdev = "wlp3s0";
  inherit (import ../nix/sources.nix {}) nixpkgs;
  withShebang = lib: a: lib.recursiveUpdate a (import ../lib/shebang.nix { inherit container_name; });

in
{lib ? pkgs.lib, pkgs ? import nixpkgs {}, ...}: withShebang lib { #TODO should already be getting a pinned pkgs from here
  imports = [ ../lib/container-outerset.nix ];

  config = {
    containers.${container_name} = {
      extra.overrideArgs = { nixosPath = nixpkgs + "/nixos"; }; #TODO figure out if i can put this in container-parent
      ipvlans = [ "${master-netdev}" ];

      config = {
        imports = [ (import ../configurations/impure.nix { system = "remote_builder"; }) ];
        inherit master-netdev;
        };
      };
    };
  }
