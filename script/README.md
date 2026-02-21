
# Build-time scripts
Make changes to the image during the building process. They are listed in their order of execution, first from the top.
| Script name | Purpose |
| --- | --- |
| dnf5.fish | Installs packages to the immutable layer with DNF5 |
| systemd.fish | Systemd related unit modifications |

# Technical aspects and decisions

## BootC > RPM-OSTree

Transitioning to bootc is intended to move system management toward a pure image-based model,
which removes client-side package management functionality.
The entire OS is defined by a container image.
3rd party inclusions the user wants needs them to use components like Flatpak and Distrobox
Faster to deploy, abide by a single source of truth ( don't do this with the human mind, it is different from a mostly deterministic computer and is meant to explore )
The maintainer ofthe image should  package software that follows logical philosophies, modern standards, performance and efficiency
requirements into the image as much as they can for best integration without excessive bloating

## Flatpak's regression

Flatpak is bad in terms of architecture due to lower efficiency and lower system integration. See https://youtu.be/f_Xa_JvpfK0 for a rough overview
Close to worthiness like Electron. Tauri is like distrobox but x100 resource efficient. Snapd is even worse.
Yet it is a solid choice for its ability to isolate programs, letting the user to install userland apps, and granularly control every app's permissions
in case you are privacy consious or accessing a system level part causes abnormal application behaviour

## TuneD > TLP > ACF

TuneD better integrated w/ modern standards, drivers, pstate support, less breakage points by low configurability=, it works dynamically as per workload
TLP has extensive configurability, potential for better power management as per config but can be poor at handling some things like modern s2idle though configurable
ACF is ok, but management is only specific to CPU, but TLP covers a lot more things better. Though auto turbo management in ACF, modern hardware already does that well.

## Pstate Active + balance_performance is better
[Gemini Chat](https://gemini.google.com/share/da75c4d35d82)

Pros of Guided:
Guided is more contextually aware than Active, better level of manipulation by governor
Governor has better control over energy scaling
Niche compatibility cases

Cons of Guided:
Guided has more overhead
Always has slower reaction time, well, unless the OS was built right into the ISA, the compositing logic or other things as instruction sets

The main reason for using Guided because schedutil is essentially what allows the CPU to indirectly understand
the current workload happening in Linux by PELT.
Else Guided without using schedutil is essentially somewhat pointless, and in that case you are better off just using Active.
Unless there is a better governor than schedutil, this is always good.

Pros of Active:
Least overhead, all processing is done within the die contacting the OS only for EPP or EPB
Most efficient and direct internal granularity
Faster responses to energy changes and performance demands
CPU adjusts itself w/o kernel dependance
Better for race to idle philosophy
Allows granular picking of power requiremements, like schedutil with certain biases and power-dire situations
In power dire situations, this is the best at handling the job

Cons of Active:
Can be less understanding to actual OS tasks

active - autonomous, good for hardware-based controlling, based on the energy performance preference
guided - guided autonomous, greater context of what is happening, based on the current workload (sensible with schedutil)
passive - governor dictates the operating frequencies (slowest)

# AMD/Intel PState > ACPI CPUFreq

Just modern, uses better CPU/hardware platform native drivers

## S2idle/S0ix > hibernate > shutdown

S2idle is built into modern CPUs for quick resume support, allows background activities to happen like updates, notifications with minimal energy drain
Worth it for most devices. Keeps things always in RAM(just the DRAM cell refresh costs almost nothing)
A bit better than S3 sleep

Hibernate is good only for battery critical situations, it reduces the lifespan of your device's storage

Shutdown requires the device to stop every process, unload everything. When the device is needed to be accessed again,
the entire process of booting needs to take place, which is more inefficient in the per long term.