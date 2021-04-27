{pkgs, lib, ...}: {
  # TODO magic incantation https://github.com/NixOS/nixpkgs/issues/16884#issuecomment-238814281
  #options.security.pam.services = with lib // lib.types; mkOption {
  #  type = attrsOf (submodule ({...}: {
  #    options.text = mkOption {
  #      apply = v: builtins.replaceStrings [ "pam_unix.so" ] [ "pam_unix.so audit debug" ] v; 
  #      };
  #    }));     
  #  };

  config = {
    services.openssh = {
      enable = true;
      permitRootLogin = "yes";
      challengeResponseAuthentication = false;
      extraConfig = ''
        PermitEmptyPasswords yes
        '';
      };

    security.pam.services.su.allowNullPassword = true;
    security.pam.services.sshd.allowNullPassword = true;
    };
  }

