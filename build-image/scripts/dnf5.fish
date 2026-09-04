#!/usr/bin/env fish
echo "🚩 --- Run 'dnf5.fish' ---"

# Notes:
    # Prefer updating/syncing system before installing packages.
    # Sometimes updating/syncing can cause conflicts or missing dependencies.
    # Specific packages with versions set from upstream base image may become broken.
    # 
    # ROCm and CUDA work in distrobox
    # Install your dev files to home folder, distrobox or flatpak.
    # They will probably work in any case.
    # Just set it up with care as it is not a traditional system.

# Aliases
    alias df5pkg- "dnf5 -y remove"
    alias df5pkg+ "dnf5 -y install --skip-broken --skip-unavailable --allow-downgrade --allowerasing"
    alias df5repo+ "dnf5 -y config-manager addrepo --overwrite --create-missing-dir"

# If the domain and its repo file is down, probably the package is not available to install as well. Even if you did mention the repo files there manually, it would not be able to retrieve the package itself.
# Futhermore, if some parameters in the DNF file change, it lets the maintainer of the package do changes from one place, without relying on downstream maintainers. GPG keys change frequently for critical projects.

# Packages Delete
    echo "⭕ --- (-) Delete packages ---"
    df5pkg- \
        moby-engine \
        firefox \
        code \
        @gnome-desktop gnome-shell gdm mutter gnome-session gnome-control-center gnome-randr gnome-initial-setup nautilus gnome-terminal \
        steam

# Repos add
    df5pkg+ fedora-gpg-keys dnf-plugins-core etckeeper-dnf dnf-repo
    df5repo+ --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    df5repo+ --from-repofile=https://packages.playit.gg/repo-files/playit-fedora.repo
    df5repo+ --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo

    dnf5 copr enable ryanabx/cosmic-epoch
    dnf5 copr enable ligenix/cosmic-ext
    dnf5 copr enable lizardbyte/beta
    dnf5 copr enable pesader/hblock
    dnf5 copr enable elxreno/preload
    dnf5 copr enable pgdev/zed

    df5pkg+ --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
    df5pkg+ "https://repo.linrunner.de/fedora/tlp/repos/releases/tlp-release.fc$(rpm -E %fedora).noarch.rpm"
    df5pkg+ https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# PackageSync
    # Distro-sync - Packages versions are set to the version meant for that version of the distro
    # for coordinated versioning.
    # 
    # Updating - Packages are bindly updated, but some may break compatibility
    # with each other and not coordinate
    # 
    # You want a system that works correctly,
    # and not just packages with a higher version that may not properly coordinate with each other.
    # Distro-sync also fixes conflicts and missing dependencies
    # Avoid on rawhide, use update instead there. 
    #echo "⭕ --- (@) Sync packages"
    #dnf5 -y distro-sync --skip-unavailable --skip-broken --allowerasing

# PackageUpdate
    # Use distro-sync instead of update
    #echo "⭕ --- (^) Update packages ---"
    #dnf5 update -y --skip-unavailable --allow-downgrade --allowerasing

# Packages Add
    echo "⭕ --- (+) Add packages ---"
    df5pkg+ \
        xdg-desktop-portal-cosmic cutecosmic-qt6 cosmic-app-library cosmic-applets cosmic-panel cosmic-workspaces cosmic-bg cosmic-comp cosmic-notifications cosmic-desktop cosmic-greeter cosmic-idle cosmic-osd cosmic-session cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon cosmic-icon-theme cosmic-launcher \
        cosmic-reader cosmic-edit cosmic-player cosmic-files \
        cosmic-ext-applet-ollama cosmic-ext-applet-tailscale cosmic-ext-applet-clipboard-manager cosmic-ext-applet-emoji-selector cosmic-ext-applet-external-monitor-brightness \
        cosmic-ext-disks cosmic-ext-examine cosmic-ext-storage cosmic-ext-tasks cosmic-ext-tweaks cosmic-ext-camera cosmic-ext-calculator cosmic-ext-xcalendar \
        \
        greetd greetd-selinux \
        \
        xdg-desktop-portal flatpak flatseal flatpak-libs flatpak-selinux flatpak-session-helper libportal \
        uutils-coreutils util-linux \
        fish zsh \
        tuned tuned-ppd tuned-utils-systemtap \
        zstd mission-center \
        bees \
        \
        hblock tor mosh tailscale openssh rsync rclone playit iwd \
        \
        waydroid waydroid-selinux \
        cockpit-podman podman \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
        distrobox
        
        #kmod-ryzen-smu kernel-modules-extra
        

    # Install your dev apps by flatpak or to distrobox,
        #amd-gpu-firmware amd-ucode-firmware amdsmi am-utils
        #nvidia-gpu-firmware libva-nvidia-driver envytools nvidia-patch
        #host-spawn libei libei-utils
        #pnpm
        #qemu-kvm qemu-kvm-core libvirt-daemon-kvm
        #mesa-va-drivers-freeworld mesa-vdpau-drivers-freeworld mesa-vulkan-drivers-freeworld mesa-dri-drivers mesa-va-drivers mesa-vdpau-drivers mesa-vulkan-drivers mesa-libOSMesa mesa-compat-libOSMesa
    # CONFLICTS # ( Format: ChosenPackages | ConflictingPackages (reason) )
        # NONE | fedora-release-identity-cosmic-atomic fedora-release-cosmic-atomic ( this independent image is NOT cosmic atomic, recognizing it as one will cause conflicts )
        # NONE | fedora-repos-rawhide ( only use repos in fsroot/usr/share/factory/etc/yum.repos.d or pre-packaged ones )
        # NONE | cosmic-config-fedora ( We have our own configs )
        # tuned tuned-ppd | power-profiles-daemon , tlp tlp-pd tlp-rdw , auto-cpufreq ( TuneD better integrated w/ modern standards, drivers, pstate support, less breakage points by low configurability )
    echo " --- (+) Add packages ---"

# Cleanup
    echo "⭕ --- (🧹) Clean DNF5 ---"
    dnf5 autoremove -y # Extra packages
    dnf5 clean all -y # Cached data
    echo " --- (🧹) Clean DNF5 ---"

echo " --- Run 'dnf5.fish' ---"