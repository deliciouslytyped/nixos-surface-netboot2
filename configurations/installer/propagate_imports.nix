[ #TODO move to same server as pxe server?
   ./sshd.nix (import (((import ../../nix/sources.nix).nixos-hardware) + "/microsoft/surface/default.nix")) /*tar issue wontfix link*/ ./builder.nix ./justdoit.nix
   ]
