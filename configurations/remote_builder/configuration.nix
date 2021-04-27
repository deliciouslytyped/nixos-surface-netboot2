{pkgs, ...}: {
  options.master-netdev = lib.mkOption { type = lib.types.str; };
  config = {
    networking.interfaces."iv-${config.master-netdev}".useDHCP = true;

    #TODO boot.initrd uses udhcpc do i need to do anything about that?
    networking.dhcpcd.extraConfig = ''
      broadcast
      clientid bdx
      '';

    services.openssh.enable = true;
    users.mutableUsers = false;
    users.users.buildergate = {
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHrsFdTs3svHjZc1E6UkOlCGgCWxWKyGyh9CJKWkfq1/" ];
      isNormalUser = true; #TODO unf*** see note #??
      extraGroups = [ "wheel" ];
      uid = 2000; #matches the uid on the host...
      };
    };
  }
