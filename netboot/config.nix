args@{config, lib, ...}: with lib; {
#  disabledModules = [ "services/networking/dnsmasq.nix" ];

  imports = [ 
    ./netboot_server.nix
    #./dnsmasq.nix
    #./dnsmasq-service.nix
    #../installer/fastercompress.nix
    ];
  options = {
    netboot_server = mkOption {
      type = types.attrs;
      description = "";
      };
#    netboot_server = {
#      network.wan = mkOption {
#        type = types.str;
#        description = "the internet facing IF";
#        };
#      network.lan = mkOption {
#        type = types.str;
#        description = "the netboot client facing IF";
#        };
#      internal_ip = mkOption {
#        type = types.str;
#        description = "";
#        };
#      internal_subnet_root = mkOption {
#        type = types.str;
#        description = "";
#        };
#      };
    };

  config = {
    netboot_server.network.wan = "iv-iv-wlp3s0";
    netboot_server.network.lan = "iv-iv-wlp3s0";
    netboot_server.internal_ip = "192.168.0.12";
    netboot_server.internal_subnet_root = "192.168.0";
    };
  }
