# previous art for auth https://logs.nix.samueldr.com/nixos/2019-06-19#2321397
#TODO see also https://gist.github.com/danbst/09c3f6cd235ae11ccd03215d4542f7e7
{pkgs, ...}: {
  nix.buildMachines = [ {
    hostName = "192.168.0.118";
    sshUser = "buildergate";
    sshKey = "/etc/nixos/secrets/bld.priv";   
    system = "x86_64-linux";
    maxJobs = 4;
    speedFactor = 2;
    supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
    mandatoryFeatures = [ ];
    } ];
  nix.distributedBuilds = true;
  nix.binaryCaches = [ "ssh-ng://buildergate@192.168.0.118" ];
  nix.binaryCachePublicKeys = [ "buildergate:sePTy8sOSZf/dJC9UDNGtUpO2NtZl18kLLmXof4Rslw=" ];
  #TODO this doesnt work for some reasonsystemd.services.nix-daemon.environment.SSH_AUTH_SOCK = "/root/nix-bld-auth.sock";
  #systemd.services.nix-daemon.environment.NIX_SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"; #TODO bad?

  nix.envVars = {
    SSH_AUTH_SOCK = "/root/nix-bld-auth.sock";
    NIX_SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"; #TODO bad? #TODO disable this if not in the installer image?
    };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "add-builder-key" ''
      eval `ssh-agent -a /root/nix-bld-auth.sock`
      ssh-add /etc/nixos/secrets/bld.priv
      '')
    ];
  }
