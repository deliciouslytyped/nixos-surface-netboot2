# Inspired by https://github.com/cleverca22/nix-tests/blob/master/kexec/justdoit.nix
{pkgs, ...}:
let
  cfg = {
    };

  #TODO wipefs? #TODO make rerunning it fine (eg. the mounts)
  jdscript = pkgs.writeShellScriptBin "justdoit" ''
    #TODO use this elsewhere?
    function cpcfg() {
      cp -ar "$1" "$2"
      rm "$2"/configurations/impure/system
      }

    source /etc/profile # get stuff in path #TODO this is a bit of a hack to get the systemd service to work
    set -euo pipefail
    swapon /dev/disk/by-label/NBT_TARG_SWP
    mount /dev/disk/by-label/NBT_TARG /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/NBT_TARG_BT /mnt/boot
    nixos-generate-config --root /mnt --dir /etc/nixos/configurations/impure/generated
    cpcfg /etc/nixos/. /mnt/etc/nixos
    echo -n system > /mnt/etc/nixos/configurations/impure/system
    mkdir -p /etc/nixos/configurations/impure/imports/
    cat >/etc/nixos/configurations/impure/imports/generated.nix <<EOF
    {...}: {
      boot.loader.grub.device = "nodev"; 
      #users.users.root.initialPassword = "root"; #TODO why doesnt this work?
      users.users.root.password = "root";
      users.mutableUsers = false; #qyliss said this is needed for it to change existing passwords
      }
    EOF
    nixos-install --no-root-passwd
    swapoff /dev/disk/by-label/NBT_TARG_SWP

    #TODO I haven't been able to figure out if it's possible to kexec grub, so we use this hack and parse out the first (which I hope is the right one)
    # entry in the grub.cfg
    kernel=$(cat /mnt/boot/grub/grub.cfg | grep -E '^[ ]*linux' | grep -Eo 'linux.*' | head -n1 | cut -f 2- -d " " | cut -f 2- -d "/" | cut -f 1 -d " ") # Expecting; linux ($drive1)//kernels/gpzqm7pn3465ks3lvjzgivvdlk99x89z-linux-5.10.19-bzImage init=/nix/store/lvdz0bhw61w1msyaklzhr7dc0py7jpxs-nixos-system-nixos-21.05pre-git/init mem_sleep_default=deep loglevel=4
    cli=$(cat /mnt/boot/grub/grub.cfg | grep -E '^[ ]*linux' | grep -Eo 'linux.*' | head -n1 | cut -f 2- -d " " | cut -f 2- -d "/" | cut -f 2- -d " ")
    initrd=$(cat /mnt/boot/grub/grub.cfg | grep -E '^[ ]*initrd' | head -n1 | cut -f 2- -d "/") # Expecting; initrd ($drive1)//kernels/994n93wipi27ism4k06f9cj3458frbjb-initrd-linux-5.10.19-initrd
    set -x
    kexec -l "/mnt/boot/''${kernel}" --append="''${cli}" --initrd="/mnt/boot/''${initrd}"
    kexec -e

    # todo generate ssh key, asymmetrically encrypt and deposit on server
    # suspend pxe for a few secodns #TODO idk any better way to do this -> actually; chainload the system (kexec?)
    # reboot into system
    '';
in {
  environment.systemPackages = [ jdscript ];
  systemd.services.justdoit = {
    serviceConfig = { #NOTE needs 
      ExecStart = "${jdscript}/bin/justdoit";
      };
    };
  }
