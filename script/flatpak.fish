#!/usr/bin/env fish

# 📛 Alias
alias fpk "flatpak --system" # Main alias
alias fpkRep+ "flatpak --system remote-add --if-not-exists" # Repository add
alias fpkRep- "flatpak --system remote-delete --force" # Repository remove
function fpkPkg+ -d "Flatpak add packages with additional checks, right now incomplete"
    set -l remote $argv[2]
    set packages $argv
    if test (count $argv) -eq 1 -a -n (string match '* *' $argv[1])
        set packages (string split ' ' $argv[1])
    end
    set -l install_list
    for pkg in $packages
        # Search and parse output (tab-separated by default)
        set -l output (flatpak search --columns=application,remotes $pkg $scope 2>/dev/null)
        if test -z "$output"
            continue  # No results
        end
        set -l lines (string split \n -- $output)
        # Skip header if present
        set -l found false
        for line in $lines[2..-1]  # Assume first line is header
            set -l fields (string split \t -- $line)
            set -l candidate $fields[1]
            set -l remotes $fields[2]
            if test "$candidate" = "$pkg"
                # Exact match; check if our remote is available
                if string match -q "*$remote*" $remotes
                    set found true
                    break
                end
            end
        end
        if $found
            set install_list $install_list $pkg
        end
    end
    if test (count $install_list) -gt 0
        flatpak --system install -y --noninteractive --or-update $remote $install_list
    end
end
alias fpkPkg+Adv "flatpak --system install -y --noninteractive --or-update"
alias fpkPkg- "flatpak --system uninstall -y --noninteractive" # Package remove

# REP ( - Removal )

# REP ( + Install )
  fpkRep+ flathub https://flathub.org/repo/flathub.flatpakrepo
  fpkRep+ flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo
  ###fpkRep+ eos-sdk https://ostree.endlessm.com/ostree/eos-sdk
  fpkRep+ igalia https://software.igalia.com/flatpak-refs/igalia.flatpakrepo
  fpkRep+ dragon-nightly https://cdn.kde.org/flatpak/dragon-nightly/dragon-nightly.flatpakrepo
  ###fpkRep+ eos-apps https://ostree.endlessm.com/ostree/eos-apps
  fpkRep+ webkit https://software.igalia.com/flatpak-refs/webkit-sdk.flatpakrepo
  fpkRep+ gnome-nightly https://nightly.gnome.org/gnome-nightly.flatpakrepo
  fpkRep+ webkit-sdk https://software.igalia.com/flatpak-refs/webkit-sdk.flatpakrepo
  fpkRep+ fedora oci+https://registry.fedoraproject.org
  fpkRep+ fedora-testing oci+https://registry.fedoraproject.org/#testing
  ###fpkRep+ rhel https://flatpaks.redhat.io/rhel.flatpakrepo
  fpkRep+ eclipse-nightly https://download.eclipse.org/linuxtools/flatpak-I-builds/eclipse.flatpakrepo
  fpkRep+ elementaryos https://flatpak.elementary.io/repo.flatpakrepo
  fpkRep+ pureos https://store.puri.sm/repo/stable/pureos.flatpakrepo
  fpkRep+ kde-runtime-nightly https://cdn.kde.org/flatpak/kde-runtime-nightly/kde-runtime-nightly.flatpakrepo
  fpkRep+ cosmic https://apt.pop-os.org/cosmic/cosmic.flatpakrepo

# PKG ( - Removal )
   flatpak uninstall -u --all -y --noninteractive --force-remove ## System wide Flatpaks standardize location and save storage, yet data stays separate for users.

# PKG ( + Install )

    fpkPkg+Adv \
      org.gnome.Platform org.gnome.Sdk \
      org.freedesktop.Platform org.freedesktop.Sdk.Extension.rust-nightly org.freedesktop.Platform.ClInfo org.freedesktop.Platform.codecs-extra org.freedesktop.Platform.ffmpeg-full org.freedesktop.Platform.GL.default org.freedesktop.Platform.GL.mesa-git org.freedesktop.Platform.GL32.default org.freedesktop.Platform.GL32.mesa-git org.freedesktop.Platform.GlxInfo org.freedesktop.Platform.GStreamer.openmpt org.freedesktop.Platform.openh264 org.freedesktop.Platform.VAAPI.Intel org.freedesktop.Platform.VAAPI.nvidia org.freedesktop.Platform.VaInfo org.freedesktop.Platform.VdpauInfo org.freedesktop.Platform.VulkanInfo \
      org.freedesktop.Platform.VulkanLayer.gamescope org.freedesktop.Platform.VulkanLayer.MangoHud org.freedesktop.Platform.VulkanLayer.OBSVkCapture org.freedesktop.Platform.VulkanLayer.vkBasalt \
      org.kde.Platform org.kde.Sdk org.kde.PlatformTheme.QtSNI org.kde.PlatformTheme.QGnomePlatform
    
    fpkPkg+Adv \
      org.freedesktop.Platform.VulkanLayer.lsfgvk//25.08 org.freedesktop.Platform.VulkanLayer.lsfgvk//24.08

# Use "app.zen_browser.zen" over "org.mozilla.firefox" - Polished experience
# Use "com.google.ChromeDev" over "com.google.Chrome" - Faster updates

  fpkPkg+Adv flathub \
    com.rafaelmardojai.Blanket \
    edu.berkeley.BOINC \
    io.github.flattool.Warehouse com.github.tchx84.Flatseal \
    org.vinegarhq.Sober io.mrarm.mcpelauncher app.twintaillauncher.ttl com.heroicgameslauncher.hgl \
    rocks.shy.VacuumTube com.spotify.Client org.js.nuclear.Nuclear com.warlordsoftwares.youtube-downloader-4ktube io.github.ecotubehq.player \
    com.ranfdev.DistroShelf org.gnome.Boxes rs.ruffle.Ruffle \
    io.github.brunofin.Cohesion org.onlyoffice.desktopeditors \
    io.frama.tractor.carburetor com.termius.Termius dev.deedles.Trayscale \
    io.github.qwersyk.Newelle org.upscayl.Upscayl \
    org.telegram.desktop io.github.tobagin.karere dev.vencord.Vesktop \
    com.github.wwmm.easyeffects org.nickvision.cavalier com.spotify.Client \
    io.missioncenter.MissionCenter

# Although more feature rich, "com.rtosta.zapzap" has several inconsitencies and higher resource consumption. "io.github.tobagin.karere" just works well with native libraries
# No using VSCode flatpaks "com.visualstudio.code com.visualstudio.code.tool.fish com.visualstudio.code.tool.podman" - Bazzite-DX already has it

    fpkPkg+Adv cosmic \
      io.github.cosmic_utils.cosmic-ext-applet-clipboard-manager \
      io.github.cosmic_utils.cosmic-ext-applet-external-monitor-brightness \
      io.github.cosmic_utils.minimon-applet
