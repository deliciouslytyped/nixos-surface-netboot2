#TODO add mac filter for when i accidentally the public netowrk?
{config, ...}: let
  hostAddress = config.netboot_server.internal_ip;
  hostSubnetRoot = config.netboot_server.internal_subnet_root;
  netdev = "wlp3s0";
in {
#TODO hm though interestingly apparently dchlient wont pull an ip if i run it on the same interface as the container, but thats for later
  #TODO docs
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    extraConfig = ''
      # Íhttps://wiki.fogproject.org/wiki/index.php?title=ProxyDHCP_with_dnsmasq
      # https://www.theurbanpenguin.com/pxelinux-using-proxy-dhcp/
      port=0  
      log-dhcp
      #TODO if direct mode
      # https://blog.stigok.com/2017/03/11/setting-up-a-dhcp-server-with-dnsmasq.html "no address range available for DHCP request via"
#      interface=${netdev}
      listen-address=${hostAddress}
#      dhcp-range=${hostSubnetRoot}.0,${hostSubnetRoot}.255,255.255.255.0
#TODO wait what i had this on?

#      dhcp-authoritative
      dhcp-range=${hostAddress},proxy,255.255.255.0
      dhcp-no-override #https://wiki.fogproject.org/wiki/index.php?title=ProxyDHCP_with_dnsmasq

#      dhcp-boot=undionly.kpxe,,${hostAddress}
#      dhcp-vendorclass=UEFI,PXEClient:Arch:00007
      # shouldnt this be 64?
#      dhcp-boot=net:UEFI,x86_64-ipxe.efi,,${hostAddress} #TODO these are actually needed when ipxe queries them and not proxydhcp?
      #TODO not sure i need the detour thrugh pxe?
      dhcp-userclass=set:PXE,iPXE
      dhcp-boot=net:PXE,http://${hostAddress}/boot.php,,${hostAddress}
#      dhcp-authoritative
#      pxe-service=net:#ipxe,x86PC, "splashtop by richud.com", netboot.xyz.kpxe

#      pxe-prompt="Press F8 for boot menu", 10 #TODO seems like proxydhcp wants these options instead of dhcp-boot?
      pxe-service=net:!PXE,X86-64_EFI, "F*CK",x86_64-ipxe.efi #ugh there has to be a better way to do this, it bootloops if i dont negate the tag, but i seem to need to use this to use proxydhcp #im probably doing something wrong, other people dont need this?
      '';
    };
  }

