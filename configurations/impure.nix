#This file is _intended_ to capture all impurities
{system ? __readFile ./impure/system }: {lib, ...}:
let
  mapDirFiles = f: path: builtins.mapAttrs (n: _: f (path + ("/" + n))) (builtins.readDir path);
in {
  options = {
    copyToTarget = lib.mkOption { type = lib.types.bool; }; #TODO
    target = lib.mkOption { type = lib.types.string; default = "/etc/nixos/"; }; #TODO
    };
  imports = [
    (./. + "/${system}/configuration.nix") #TODO use line splitting to be more editing friendly
    ] ++ (if (__elem "generated" (__attrNames (__readDir ./impure))) then [(import ./impure/generated/hardware-configuration.nix)] else []) # TODO 
      ++ (lib.traceVal (if (__elem "imports" (__attrNames (__readDir ./impure))) then (__attrValues (mapDirFiles import ./impure/imports)) else []));
  config = {
    #TODO test the activation script
    system.activationScripts = { impureMarker.text = ''
      #TODO *should* be idempotent/usable with an existing system
      if [ ! -d  /etc/nixos/impure ]; then
        # https://askubuntu.com/questions/86822/how-can-i-copy-the-contents-of-a-folder-to-another-folder-in-a-different-directo
        cp -ar ${../.}/. /etc/nixos/ #TODO dont like this being a store copy
        chmod 600 -R /etc/nixos/secrets #TODO not very secret
        chmod +w -R /etc/nixos
        mkdir -p /etc/nixos/configurations/impure
        ln -fs ${../.} /etc/nixos/configurations/impure/current-system #TODO this is annoying for diff usage since it contains itself? - well you should just be using git then
      fi
      # We want to touch the impure directory on the target system, not the source repository by accident.
      # This can happen/be wrong if the path is resolved with the expression running in the container host (?), or the 
      # repository is mounted rw in e.g. /configs/whatever.
      # Additionally if its such a conflicting location, youd have conflicts depending on wihc container was last built, etc.
      # This means, for this to behave as desired, we must make a copy of the configuration to the target.
      # That is why the previous operation exists. TODO: note stuff i dont like / do better? -e.g. i don tlike the hardcoded /etc
      #echo "${system}" > ${builtins.toString ./impure/system}
      echo -n "${system}" > /etc/nixos/configurations/impure/system # NOTE no newline so it doesn't show up in the ''${system} substitution in impure.nix.
      ''; };
    };
  }
