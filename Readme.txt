WARNING: for some reason it takes a while after container boot for PXE to work properly? - or my network/DHCP is unreliable and IDK why
Another iteration of https://github.com/deliciouslytyped/nixos-surface-netboot .
(TODO: import that repo into an orphan branch in this one)
TODO: currently the networking configuration may not be robust (beyond adding the physical devices)

This contains nix code for running a set of two containers: a pxe server and a remote
builder gateway, to load and install a system with a patched kernel over PXE on a
Microsoft Surface 3 (non-pro).

The pxe image contiains a script (justdoit.nix) which installs the system, propagates
this repository into it, and boots it via kexec. So it's mostly (not quite there yes,
and the PXE boot is a bit unreliable for some reason) a plug-and-play hands-free way
to boot the device and offload any builds to a more powerful device.

Some networking shenanigans, specifically ipvlan, and consequences of ipvlan, are due
it not being possible (without difficulty) (??TODO substantiate) to bridge WLAN
interfaces. This is needed to be able to run the DHCP server needed for PXE from
inside a container.

A portion of additional code deals with making dealing with all of this a bit more ergonomic,
i.e. this is not the most minimal possible example to do this.
