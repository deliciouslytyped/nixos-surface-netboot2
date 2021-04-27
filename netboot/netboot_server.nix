#TODO netboot with remote store for smaller image?
#TODO fast image generation (dont use squashfs)
#TODO streamline install process
{ lib, config, ... }:
with lib;
let
  #TODO note somehow clarify that the container setup uses the host ...etc
  pkgs = import (import ../nix/sources.nix {}).nixpkgs {};

  netboot = let
    build = (import (pkgs.path + "/nixos/lib/eval-config.nix") {
      system = "x86_64-linux";
      modules = [
        (pkgs.path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
#        ../configurations/installer/default.nix
#        ((import (import ../nix/sources.nix).nixpkgs {}).path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
        (import ../configurations/impure.nix { system = "installer"; })
        ];
      }).config.system.build;
      in pkgs.symlinkJoin {
        name = "netboot";
        paths = with build; [ netbootRamdisk kernel netbootIpxeScript ];
        };

  ipxe' = pkgs.ipxe.overrideDerivation (drv: {
    installPhase = ''
      ${drv.installPhase}
      make $makeFlags bin-x86_64-efi/ipxe.efi bin-i386-efi/ipxe.efi
      cp -v bin-x86_64-efi/ipxe.efi $out/x86_64-ipxe.efi
      cp -v bin-i386-efi/ipxe.efi $out/i386-ipxe.efi
      '';
    });
  
  tftp_root = pkgs.runCommand "tftproot" {} ''
    mkdir -pv $out
    cp -vi ${ipxe'}/undionly.kpxe $out/undionly.kpxe
    cp -vi ${ipxe'}/x86_64-ipxe.efi $out/x86_64-ipxe.efi
    cp -vi ${ipxe'}/i386-ipxe.efi $out/i386-ipxe.efi
    '';
  
  #TODO unf*** the non authoritative dns server thing with getting a second different ip from the initial pxe load and the ip changing and so trying to load from the wrong url?
  nginx_root = pkgs.runCommand "nginxroot" {} ''
    mkdir -pv $out
    cat <<EOF > $out/boot.php
    #!ipxe
    chain http://192.168.0.12/netboot/netboot.ipxe
    EOF
    ln -sv ${netboot} $out/netboot
    '';
  
  cfg = config.netboot_server;

in {
  config = {
    services = {
      nginx = {
        enable = true;
        virtualHosts = {
          "${config.netboot_server.internal_ip}" = {
            root = nginx_root;
            };
          };
        };
      atftpd = {
        enable = true;
        root = tftp_root;
        extraOptions =  [  "--verbose=5" ];
        };
      bind = {
        enable = true;
        cacheNetworks = [ "${config.netboot_server.internal_subnet_root}.0/24" "127.0.0.0/8" ];
        };
      };
    };

  }
