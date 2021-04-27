#TODO i need some kind of like, pxe-ping tool or something
let
  master-netdev = "iv-wlp3s0";
in
{
  #TODO figure out why pxe doesnt work intermittently / takes a while to work after restarting container
 #TODO how do i force updated of the inner container when i make extra container do its outer container reinstall thing?
  #TODO mkmerge gen-network
  imports = [
    ../lib/container-outerset.nix
    #(gen-network ...)
    ];

  containers.pxeserver = {
    # extraVeths."iv-iv-wlp3s0".localAddress = "192.168.0.12"; #TODO dhcp?    
    extra.overrideArgs = { nixosPath = (import ../nix/sources.nix {}).nixpkgs + "/nixos"; }; #TODO figure out if i can put this in container-parent
    ipvlans = [ master-netdev ];
    config = {
      imports = [ (import ../configurations/impure.nix { system = "pxe_server"; }) ];
      inherit master-netdev;
      };
    };
  }
