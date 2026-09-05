# Technical aspects, decisions, explanations

## Stable VS Prerelease

Prefer stable software, unless there is a good reason to use a beta version and
bake it into the image. For example, COSMIC cannot be ran directly through distrobox.
Nested Wayland is only for debugging and not regular use.

And you can switch to another provider, so you do not have to be forced to use
your OEM provided bootc image
which they may compile on their side but may have components you do not like or
some integrated proprietary disruptive applications

Warning, manually moving the contents or symlinking them to each other is prone
to disasters like cookie and auth invalidation

## BootC > RPM-OSTree

Transitioning to bootc is intended to move system management toward a pure
image-based model,
which removes OS native client side package management functionality.
The entire OS is defined by a container image.
3rd party inclusions the user wants needs them to use components like Flatpak
and Distrobox
Faster to deploy, abide by a single source of truth.
Side note, don't do this with the human mind which the, it is different from a
computer and is meant to explore, be creative, have its own opinions
The maintainer of the image should package software that follows logical
philosophies, modern standards, performance, stability and efficiency
requirements into the image as much as they can for best integration without
excessive bloating.

## AerynOS was interesting, didn't meet requirements

This was a cool experiment, an OS made from scratch, a specialized
package manager, live updates. All a modern power user can ask for!
Deltaic updates, unlike BootC, where some layers are just too big.
Moss was lightning fast at installation of packages. This abandoned
legacy packaging altogether, compared to Fedora BootC images that
still rely on DNF5, not meant for that purpose, but it just works.
However, the main requirements were atomicity, immutability, rollbacks
and orchestration and single source of truth. The freedom of using moss
gave me the illusion this was better, due to everything being available as a
native packages. But this also meant the user can also accidentally remove core
packages, resulting in failures. Distrobox exists, homebrew, VMs. They still
dont catch the vibe of it. BootC should have the ability to perform delta
updates at a granular level, all I can ask for and parallel layer downloads.

### Issues regarding Flatpak

Flatpak is bad in terms of architecture due to lower efficiency, storage/RAM
consumption and lower system integration and slower execution.
See <https://youtu.be/f_Xa_JvpfK0> for a rough overview. Analogize it like
Electron/Flatpak vs Tauri/Distrobox

Yet it is a solid choice for its ability to isolate programs, letting the user
to install userland apps, and granularly control every app's permissions
for privacy or letting something access a system level part is causing
unfavourable or abnormal behaviour for that specific package.
Snap is even worse.

## TLP > TuneD > PPD > ACF

TuneD for modern standards, drivers, pstate support, less
breakage points by low configurability, it works dynamically as per workload
PPD is like TuneD but highly restrictive to just 3 power profiles
TLP has extensive configurability like 
ACF can only do CPU-level power management

Running TLP and ACF(auto-cpufreq) together is possible but not recommended.
Both tools attempt to write to the same /sys/devices/system/cpu/ files, leading to potential conflicts.
It is recommended to use one tool at a time to prevent fluctuations and overhead.

TLP is better than ACF
Greater system power management control
ACF just enables and disabled the allowance of Turbo Boost, not its enforcement
ACF is a userspace tool, so it responds slowly to changes


## PState active + balance_power

Active is autonomous, good for hardware-based controlling, based on the energy
performance preference (imagine schedutil but more granular as per energy demands)
Least overhead, all power management processing is done on the hardware
OS contact is minimal, only for EPP or EPB. Internally granular.
It is independent of the OS scheduler, so low latency.
Good for race to idle philosophy. Availble for AMD and Intel.
Only 2 sensible options are there, out of which only 1 is better

Powersave governor + balance_power
Lets the device use as much power as possible, but still bias to energy efficiency

Powersave governor + balance_performance
Same as Powersave governor + balance_power, but with a higher performance bias
Can be less efficient

Guided is just Active but with OS imposed restrictions, by legacy schedulers
like conservative, performance with acpi_cpufreq. But they are not as aware as
the hardware about what is actually needed to be done.
The have room for misconfigurations, capping or overboosting performance by OS.
Previously, I imagined schedutil+guided to be better, due to PELT awareness,
but it was not as efficient as Active, and furthermore, greater complexity.
PELT is only better in passive mode, but has more latency and overhead.

passive - governor dictates the operating frequencies (slowest)

Only in the case of something of MacOS, everything is integrated, by process
awareness like PELT, with the added modulation of the hardware. Ideally the best.

## AMD/Intel PState > ACPI CPUFreq

Platform native control

## S2idle/S0ix > hibernate > shutdown

S2idle is built into modern CPUs for quick resume support, allows background
activities to happen like updates, notifications with minimal energy drain
Worth it for most devices. Keeps things always in RAM(just the DRAM cell refresh
costs almost nothing). A bit better than S3 sleep

Hibernate is good only for battery critical situations, frequest usage reduces
the lifespan of your device's storage

Shutdown requires the device to stop every process, unload everything. When the
device is needed to be accessed again, the entire process of booting needs to
take place, which is more inefficient in the long term. The image blocks the
ability for you to even do this.

## Better method to trigger a system update by systemd timers

### Method A: - Monotonic, independent of wall/NTP clock (Better)

With OnUnitInactiveSec, the system gets some 'x' time to rest after the service finishes.
Updates are staggered across devices to avoid overloading the package download speeds.
This is caused by factors like entropy, disk I/O, network parameters, etc.
OnUnitInactiveSec does not care if the unit ended successfully or with an error.
For OnUnitInactiveSec to actually work, it needs a reference time, else it will not trigger.
OnBootSec helps resolve that by providing a definite timestamp.
This is better for updates because,
Your system gets a grace period from boot before the update is triggered.
and between updates, the system has time to settle down.
Furthermore, natural staggering helps load balance updates across devices.

### Method B: - Real-time, based on wall/NTP clock

AccuracySec allows timers to be auto-rescheduled and coalesced within the next 'x' hours/minutes/seconds.
Persistent=true runs service immediately if it misses the scheduled time it was supposed to get activated at.
OnCalendar=00,04,08,12,16,20:00:00 UTC attempt to run 6 times day, and this can be forced to follow a specific timezone, here UTC

This is fine, but not optimal for updates because, lets assume the following scenario,
You open your laptop for a quick task and the system is immediately faced with a huge update to apply.
Heavy lag on boot, is not ideal.
Also, if you start your device at 3:56 PM and an update is ongoing, an unnecessary update check will be triggered at 4:00 PM.
It is blind to the fact that an update is already in progress and will trigger a new one, but one is already in progress or just ran a few minutes ago.
Furthermore, server overloading is a common issue when using this method.

### Method C: - Event-driven

This is mostly impractical for consumer devices, but for mission critical devices, it is a good option.
A server that hosts the update events and triggers updates on the devices immediately when they are available.
No independent timers, but the risk is centralized failure. Even if the center fails, there is no way you can update anyways.
However, if a P2P network is available, you can use it to distribute updates without a central server.
