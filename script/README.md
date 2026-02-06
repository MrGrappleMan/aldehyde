
# Build-time scripts
Make changes to the image during the building process. They are listed in their order of execution, first from the top.
| Script name | Purpose |
| --- | --- |
| dnf5.fish | Installs packages to the immutable layer with DNF5 |
| systemd.fish | Makes Systemd consider the correct service files to run from |

# Technical aspects and decisions

## BootC > RPM-OSTree

Transitioning to bootc is intended to move system management toward a pure image-based model,
which removes client-side package management functionality.
The entire OS is defined by a container image.
3rd party inclusions the user wants needs them to use components like Flatpak and Distrobox
Faster to deploy, abide by a single source of truth ( don't do this with the human mind, it is different from a mostly deterministic computer and is meant to explore )
I package software that follows logical philosophies, modern standards, performance and efficiency requirements into the image as much as I can for best integration.

## Flatpak's regression

Flatpak is bad in terms of architecture due to lower efficiency, higher overhead with lower system integration. See https://youtu.be/f_Xa_JvpfK0 for a rough overview
Close to worthiness like Electron. Tauri is like distrobox but x100 resource efficient. Snapd is even worse.

## TuneD > TLP > ACF

TuneD better integrated w/ modern standards, drivers, pstate support, less breakage points by low configurability...and it literally has dynamic in its service's description
TLP has extensive configurability, potential for better power management as per config but can be poor at handling some things like modern s2idle though configurable
ACF is ok, but management is only specific to CPU, but TLP covers a lot more things better. Though auto turbo management in ACF, modern hardware already does that well.

## Pstate (Guided > Active) + schedutil is great

## S2idle/S0ix > hibernate > shutdown

S2idle is built into modern CPUs for quick resume support, allows background activities to happen like updates, notifications with minimal energy drain
Worth it for most devices. Keeps things always in RAM(just the DRAM cell refresh costs almost nothing)
A bit better than S3 sleep

Hibernate is good only for battery critical situations, it reduces the lifespan of your device's storage

Shutdown requires the device to stop every process, unload everything. When the device is needed to be accessed again,
the entire process of booting needs to take place, which is more inefficient as per long term.
