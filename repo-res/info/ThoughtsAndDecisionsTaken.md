## Technical aspects and decisions

Explaining the reasons why a specific technical decision was taken

### Stable VS Prerelease

Alias the word 'prerelease' as 'prl' for this section

While MrGrappleMan, the creator of this project prefers prerelease software
Some users might be frustrated that they have to manually install stable software
if prl is bundled into the image.
Totally understandable, we want a reliable workstation that is easy to use and
even be suitable for use in production.
So this project, and ideally any project shouldn't be using Rawhide repos by
default in that case.

Maybe the ability to let the users use another release tag or branch while
rebasing to this image
like rawhide(rawhide repos) instead of latest(stable)
But a Traditional Fedora KVM can be better to debug in real time, or the user can
use this bootc image itself in KVM with the rawhide tag
and use the bootc usr-overlay command for a more accurate analysis on how the image
might end up when deployed to the device

Bundle stable software into the image that has a beta counterpart which the user
can install via Distrobox(manually)
provided that the software does not lose any access to the system's fundamental
components like dbus

Microsoft is literally testing in production right now, giving Windows 11 bad
additions, but in bootc the risks as reduced
as the ability to rollback is integrated and there is no way to disable it unless
the image is non compliant in that way.
And you can switch to another provider, so you do not have to be forced to use
your OEM provided bootc image
which they may compile on their side but may have components you do not like or
some integrated proprietary disruptive applications

Some things may not be a 100% compatible, like Brave and Brave Nightly where
contents are stored in different directories
Warning, manually moving the contents or symlinking them to each other is prone
to disasters like cookie and auth invalidation

### BootC > RPM-OSTree

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

### AerynOS was interesting, didn't meet requirements

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

### TuneD > PPD > TLP > ACF

TuneD better integrated w/ modern standards, drivers, pstate support, less
breakage points by low configurability, it works dynamically as per workload
PPD is like TuneD but highly restrictive to just 3 power profiles
TLP has extensive configurability, potential for better power management as per
config but can be poor at handling some things like modern s2idle though configurable
ACF is ok, but management is only specific to CPU, but TLP covers a lot more
things better. Though auto turbo management in ACF, modern hardware already does
that well.

### Pstate Active + balance_performance is better

[Gemini Chat](https://gemini.google.com/share/da75c4d35d82)

Pros of Guided:
Guided is more contextually aware than Active, better level of manipulation by governor
Governor has better control over energy scaling
Niche compatibility cases

Cons of Guided:
Guided has more overhead
Always has slower reaction time, well, unless the OS was built right into the
ISA, the compositing logic or other things as instruction sets

The main reason for using Guided because schedutil is essentially what allows
the CPU to indirectly understand
the current workload happening in Linux by PELT.
Else Guided without using schedutil is essentially somewhat pointless, and in
that case you are better off just using Active.
Unless there is a better governor than schedutil, this is always good.

Pros of Active:
Least overhead, all processing is done within the die contacting the OS only
for EPP or EPB
Most efficient and direct internal granularity
Faster responses to energy changes and performance demands
CPU adjusts itself w/o kernel dependance
Better for race to idle philosophy
Allows granular picking of power requiremements, like schedutil with certain
biases and power-dire situations
In power dire situations, this is the best at handling the job

Cons of Active:
Can be less understanding to actual OS tasks

active - autonomous, good for hardware-based controlling, based on the energy
performance preference (imagine schedutil but more granular as per energy demands)
guided - guided autonomous, greater context of what is happening, based on the
current workload (sensible with schedutil)
passive - governor dictates the operating frequencies (slowest)

### AMD/Intel PState > ACPI CPUFreq

Just modern, uses better CPU/hardware platform native drivers

### S2idle/S0ix > hibernate > shutdown

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
