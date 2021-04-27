#! /usr/bin/env nix-shell
#! nix-shell -i "bash -c '$(nix-build $EXTRA_NIX_ARGS -A config.shebang.fast --no-out-link \"$1\") \"$@\"' --" -p ""

# e.g. EXTRA_NIX_ARGS="-v --show-trace" ./nest.nix --build-args -v
# CNT_MODE="destroy nest" ./nest.nix  
#TODO bind mount a directory from the host as a pxe target directory
#TODO neat thing is extra-containers approach lets me cause a nested restart chain?
#TODO pxeserver doesnt rebuild on clean restart
#TODO search replace override function for modules
#TODO: niminci, basalt, and expect/nixos tests?
let
    netdev = "wlp3s0";
    container_name = "nest";
    withShebang = lib: a: lib.recursiveUpdate a (import ../lib/shebang.nix { inherit container_name; });
in
{lib ? (import (import ../nix/sources.nix {}).nixpkgs {}).lib, config ? {}, ...}: withShebang lib { # that config ?{} is sketch
  imports = [
    ../lib/container-outerset.nix
    #(gen-network ...)
    ];

  config = {
    #TODO factor networking stuff?
    #TODO mkmerge gen-network

    containers.nest = {
      extra.overrideArgs = { nixosPath = (import ../nix/sources.nix {}).nixpkgs + "/nixos"; }; #TODO figure out if i can put this in container-parent
      ipvlans = [ netdev ];

      localAddress = "10.11.0.2"; #set up networking to make pxeserver-rebuild work if it needs to fetch new stuff

      config = {
        imports = [ (import ../configurations/impure.nix { system = "nest"; }) ];
        inherit master-netdev;
        };
      };
    };
  }
