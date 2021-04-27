{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ethtool nmap 
    dhcp dhcping
    socat
    wireshark tcpdump termshark
    # https://github.com/pypxe/PyPXE, https://github.com/gmoro/proxyDHCPd ?
    iw
    (python37.withPackages (p: [ p.scapy ]))
    ];
  }
