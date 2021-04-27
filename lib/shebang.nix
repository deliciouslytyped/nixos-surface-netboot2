# Usage:
# Note, the shebang line doesn't use eval-config, so imports dont get evaled, etc., you must deep merge this in, it'snot a module
/*
#! /usr/bin/env nix-shell
#! nix-shell -i "bash -c '$(nix-build $EXTRA_NIX_ARGS -A config.passthru.shebang.fast --no-out-link \"$1\") \"$@\"' --" -p ""
*/
#TODO minimal example file
#TODO   withShebang = lib: a: lib.recursiveUpdate a (import ../lib/shebang.nix { inherit container_name; });

let
  inherit (import ../nix/sources.nix {}) nixpkgs;
  extra-container = pkgs: import ../lib/extra-container.nix { inherit pkgs; };
in
{lib ? pkgs.lib, pkgs ? import nixpkgs {}, container_name, ...}: { #TODO should already be getting a pinned pkgs from here
# we use the options and config structure to make sure module evauation doesn't complain
#TODO does upstream have a passthru attr?
#  options.shebang = lib.mkOption { type = lib.types.anything; }; 
  options.shebang = lib.mkOption { type = lib.types.anything; };#TODO figure out why passthru doesnt work

  config = {
    shebang = {      
      #TODO still evals like 50 files
      #TODO, autologin flag or something, inner rebuild flag  (???)
      fast = pkgs.writeShellScript "shebang" ''
        set -euo pipefail

        #/nix/store/j1gb4qhmqhj2p6bbsm3v5qb3pr1ij6ix-shebang ./remote_builder.nix -h
        if [ "$#" -ge "2" ] && [ "$2" = "-h" ]; then 
        cat <<HERE
        usage: EXTRA_NIX_ARGS="-v --show-trace" $1 --build-args -v
        CNT_MODE="destroy ${container_name}" ./remote_builder.nix
        HERE
        exit
        fi

        $(nix-build ''${EXTRA_NIX_ARGS:-} -A config.shebang.full --no-out-link "$1") "$@"
        '';

      full = pkgs.writeShellScript "fast-shebang" ''
        set -euo pipefail
        #${extra-container pkgs}/bin/extra-container ''${CNT_MODE:-create --start} "$@"
        #sudo cp /etc/systemd-mutable/system/container@${container_name}.service /run/systemd/system/

        #TODO fix this such that create --start works
        ${extra-container pkgs}/bin/extra-container ''${CNT_MODE:-create} "$@"
        sudo cp /etc/systemd-mutable/system/container@${container_name}.service /run/systemd/system/ #TODO this is pretty broken because this needs to happen before it starts the container
        sudo systemctl daemon-reload
        ${extra-container pkgs}/bin/extra-container ''${CNT_MODE:-start} "${container_name}"
        '';
      };
    };
  }
