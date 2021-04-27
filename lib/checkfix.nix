{...}: {
  # adds ipvlan stuff in parent containers, removes kernel version check in child containers https://github.com/NixOS/nixpkgs/issues/38509
  disabledModules = [ "virtualisation/nixos-containers.nix"];
  imports = [ ./nixos-containers.nix ]; 
  }
