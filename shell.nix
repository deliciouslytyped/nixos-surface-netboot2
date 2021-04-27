#! /usr/bin/env nix-shell
#! nix-shell -i "nix-shell -v" -p ""
let
  pkgs = import (import ./nix/sources.nix).nixpkgs {};
in
  pkgs.mkShell { buildInputs = with pkgs; [ gitFull niv ]; }
