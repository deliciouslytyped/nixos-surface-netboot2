#TODO assert container or something; we're missing the outer config obv. or make a partial configs directory?

{pkgs, config, lib, ...}: 
let #TODO
  netdev = "iv-${config.master-netdev}";
in {
  options.master-netdev = lib.mkOption { type = lib.types.str; };
  imports = [
     ../../lib/checkfix.nix <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    #        ../lib/container-innerset.nix /* can I merge this into outerset?*/
    ../../lib/network-packages.nix
    ../../netboot/dnsmasq.nix
    ../../netboot/config.nix
    ];
  config = {
    networking.interfaces."${netdev}" = { # TODO why if i multiline this?: dynamic attribute 'iv-iv-wlp3s0' at /configs/containers/pxe_server.nix:28:7 already defined at /configs/containers/pxe_server.nix:27:7
      useDHCP = false; #TODO
      ipv4.addresses = [ { address = "192.168.0.12"; prefixLength = 24; } ];
      ipv4.routes = [ { address = "192.168.0.0"; prefixLength = 24; via = "192.168.0.1"; } ];
      };
    networking.firewall.enable = false;
    networking.firewall.allowedUDPPorts = [ 67 68 ]; #TODO
    networking.firewall.allowedTCPPorts = [ 67 68 ]; #TODO
            # Make nix tooling work in nested containers
            boot.postBootCommands = pkgs.lib.mkBefore "export NIX_REMOTE=daemon\n"; # Note this means modifications to the host store #TODO upstream
            #imports = [ ]; # TODO stupid infrec... <- i'd use pkgs.path but cant in import#
    
            boot.enableContainers = true;
    };
  }
