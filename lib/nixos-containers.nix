#! /usr/bin/env nix-shell
#! nix-shell -i "bash -c 'nix-build --arg sf4g3q null \"$@\"' --" -p ""

#TODO overcomplicated
#TODO set your own <> with import scope - todo: nix-purify
{...}: let 
  nixos-containers = with import (import ../nix/sources.nix).nixpkgs {}; (applyPatches { #TODO can i get rid of this double import? :/
    src = (import ../nix/sources.nix).nixpkgs + "/nixos/modules/virtualisation/nixos-containers.nix";
    patches = lib.filesystem.listFilesRecursive ../patches/nixos-container;
    name = "nixos-containers.nix";
  }).overrideAttrs (old: { 
       unpackCmdHooks = [ "myunpack" ];
       preUnpack = "function myunpack() { mkdir source; cp \"$1\" ./source/\"$(stripHash \"$1\")\"; }\n";
       patchFlags = [ "-p0" ];
       installPhase = "cp ./nixos-containers.nix \"$out\";"; });
in {
  imports = [ (builtins.toPath nixos-containers) ];
  #test = [ nixos-containers ]; #TODO figure out why the build and run.sh are different with this
  }
