{pkgs, config, ...}: let extra-container = import ../lib/extra-container.nix { inherit pkgs; }; in {
  options.master-netdev = lib.mkOption { type = lib.types.str; }; #TODO factor
  imports = [ ../lib/network-packages.nix ];
  config = {
    environment.systemPackages = [ 
     extra-container
      #TODO genericize
      (pkgs.writeShellScriptBin "pxeserver-rebuild" ''
        systemctl daemon-reload
        extra-container create /configs/containers/pxe_server.nix --start -r --build-args -v --show-trace
        '')
      ];

    networking.defaultGateway = "192.168.0.206";
    networking.interfaces."eth0".ipv4.routes = [
      { address = "192.168.0.206"; prefixLength = 32; } #TODO uh?
      ];

    systemd.services.pxe_container = {
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/nix-daemon.nix
      path = [ config.nix.package pkgs.socat pkgs.iproute2 ];
      environment = {
        NIX_REMOTE = "daemon"; #need this to talk to the nix daemon instead of trying to do stuff ourself, i think, re: container stuff
        };
      script = ''
        ip link set iv-${master-netdev} up #TODO bit of a hack
#       socat TCP-LISTEN:4444,reuseaddr,fork EXEC:"${pkgs.bash}/bin/bash --noprofile",pty,stderr,setsid,sigint,sane
        ${extra-container}/bin/extra-container create /configs/containers/pxe_server.nix \
          --nixpkgs-path "${(import ../nix/sources.nix).nixpkgs.outPath}" `#we can almost avoid setting NIX_PATH, but for <nix>` \
          --start --restart-changed \
          --build-args -v --show-trace
        cp /etc/systemd-mutable/system/container@*.service  /run/systemd/system/
        '';
      after = [ "nix-daemon.service" ];
      wantedBy = [ "multi-user.target" ];
      }; 
    };
  }
