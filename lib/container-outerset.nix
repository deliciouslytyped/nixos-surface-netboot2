#TODO make nixos-option work in containers
let
  overrideSubmod = lib: sm: with lib; with lib.types; mkOption { type = attrsOf (submodule sm); };
in 
{config, lib, ...}: {
  imports = [ ./checkfix.nix ];  

  options.containers = overrideSubmod lib ({lib, ...}: {
    config = {
      #pinning
      nixpkgs = (import ../nix/sources.nix {}).nixpkgs;        
      #extra.overrideArgs = { nixosPath = (import ../nix/sources.nix {}).nixpkgs + "/nixos"; }; #TODO ? #see extra-container patches #see nest.nix

      ephemeral = true; #TODO: do I want this?

      bindMounts = {
        "/configs" = { hostPath = builtins.toString ../.; isReadOnly = false; };
        };

      privateNetwork = true;

      #TODO broken
      config = {pkgs, ...}: {
        # Make nix tooling work in nested containers
        boot.postBootCommands = pkgs.lib.mkBefore "export NIX_REMOTE=daemon\n"; # Note this means modifications to the host store #TODO upstream
        imports = [ ./checkfix.nix <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix> ]; # TODO stupid infrec... <- i'd use pkgs.path but cant in import#

        boot.enableContainers = true;
        };
      };
    });
  }
