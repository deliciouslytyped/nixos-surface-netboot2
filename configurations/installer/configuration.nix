#TODO nixos-enter
#TODO direct boot into via other grub
{pkgs, lib, ...}: {
  imports = (import ./propagate_imports.nix) ++ [];

  environment.noXlibs = lib.mkForce false; # https://github.com/NixOS/nixpkgs/issues/119841
    services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = "xfce";
  };
  environment.systemPackages = [ pkgs.gparted ];
}
