#! /usr/bin/env nix-shell
#! nix-shell -i "bash -c 'nix-shell --arg sf4g3q null \"$@\"' --" -p ""
{pkgs ? (import (import ../nix/sources.nix).nixpkgs {}) }:
let
  src = (import ../nix/sources.nix).extra-container;
  orig = pkgs.callPackage src { pkgSrc = src; };
  patches = pkgs.lib.filesystem.listFilesRecursive ../patches/extra-container;
in
  orig.overrideAttrs (old: { inherit patches; buildCommand = ''
    unpackPhase
    cd extra-container-src
    src=$(realpath .)
    patchPhase #TODO wat? isnt this redundant
    corepkgs="${pkgs.nix}/share/nix/corepkgs" substituteAllInPlace "eval-config.nix" #TODO I cant figure out the source of the bug this is the fix for (<nix> being /nix)
    '' + old.buildCommand + ''
    install $src/scope.nix -Dt $share
    '';
    })
