# Containerfile
#-Are you a beginner and want to know how the creation of a bootc image actually works?
#-Check out the comments below and correlate them with the repo's file structure

# CONTEXT STAGE: The repo is the source of truth
#-'ctx' means context
#-FROM in here explicitly connects the 'ctx' name to the target=/ctx folder, is where that directory name actually comes from.
FROM scratch AS ctx

# Copy all files from the repo root into the image's /ctx/ directory
#-COPY in this file serves as a 'bridge' from the repo's root and the image. The first string references the repo root, the other is the image /ctx/
#-All the files in the repo will end up in /ctx/ when seen from inside the image instance, look at the '..AS ctx' line above, thats why it is /ctx/
#-Whenever you want reference anything from /ctx/ from the Containerfile with RUN, always include '--mount=type=bind,from=ctx,source=/,target=/ctx'
COPY / /

# BASE IMAGE
#-This is the image you want to begin modifying
#-Base Image - We use Bazzite GNOME's Testing branch, check the currently used one on your device with 'sudo bootc status'
#-We did not use Bazzite GNOME DX because the pre-included tools are redundant and bloated we do not want to waste resources removing them.
#-uBlue Image list: https://github.com/orgs/ublue-os/packages
FROM ghcr.io/ublue-os/bazzite-gnome:testing

# LABELS

LABEL containers.bootc 1
LABEL org.opencontainers.image.source="https://github.com/MrGrappleMan/aldehyde-lx"
LABEL org.opencontainers.image.description="A workstation for performance"

# IMMUTABLE /opt
#-In other images, /opt is symlinked to /var/opt, to allow changes in it by the user
#-Some pkgs need this path to get installed into it
#-However since it is symlinked to /var/, it is all useless as /var/ is wiped out after building and thus /var/opt is wiped out too
#-And the user won't be able to install anything to it, there's no point in leaving it mutable. This made sense when rpm-ostree was used to layer packages.
#-Thus, some of those needed /opt to be mutable
#-Comment line below to allow modifications to it when user will be using the image, but its pointless - they can just use distrobox or other solutions
#-It makes the /opt/ directory genuine and not just a symlink
#-Brave and its keyring work best when it is inside /opt/ and is not a Flatpak
#
#-Legacy OSTree systems symlink /opt -> /var/opt to allow runtime changes with apply-live or even layering packages on the user side.
#-In a bootc build, this causes RPMs to install data into /var (that's /var/opt/) , which is
#-discarded during deployment, leaving the application missing at on the user end.
#
#-By forcing /opt to be a real directory, we ensure that Brave Browser and
#-other /opt-resident packages are captured in the immutable image layers.
#-host-side mutability is deferred to Distrobox/Containers.
RUN rm -rf /opt && mkdir /opt

# DEBUG
#-To know of any errors that might occur, uncomment them if you need to for reference

#-The below lists our that our repo to ctx copy was successful
#RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#    tree /ctx/
#RUN uname -a

# MODIFICATIONS TO IMAGE
# Make modifications to the image and install packages by modifying the build.fish script
# the below RUN directive handles "main.fish" execution as recommended while initializing the rest of familiar UNIX file paths
# avoid doing stuff from the Containerfile to avoid complexities, only minimal initialization
# https://stackoverflow.com/questions/39223249/multiple-run-vs-single-chained-run-in-dockerfile-which-is-better
# However, multiple RUNs are preferred sometimes as they help with layer caching and build reproducibility
# and more layers = more flexibility for future modifications + better resumeability support on unstable connections
# At the cost of a larger image size, but it is worth it for the benefits
# We explicitly call fish so correct interpreter is run, despite correct shebang
# Never make $home as /tmp, lots of problems will happen

## INSTALL FISH
RUN dnf5 install -y --skip-broken --allowerasing fish

## RUN MAIN.FISH
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    fish /ctx/main.fish

## DNF5
RUN echo "🚩 --- DNF5 Operations ---"

### (-) REMOVE
RUN echo "⭕ --- (-) Delete packages ---"
RUN dnf5 remove -y docker docker-compose moby-engine \
    firefox \
    code \
    gnome-shell gdm mutter gnome-session gnome-control-center gnome-initial-setup nautilus

### (@) SYNC, distro derived versioning of packages
#-in comparision to updating, this ensures that the system is in a reliable state matching the exact versions of
#-packages meant for that version of the distro, abiding more by single source of truth.
#-While updating, some thing might progress, but others might break, you want a system that works correctly
#-and not just packages with a higher version number that may not properly coordinate with each other.
#-This also ensures as a way that things are re-initializated before updating, if you want to.
#-Works best with non rawhide versions of the distro.
RUN echo "⭕ --- (@) Sync packages ---"
RUN dnf5 -y distro-sync --skip-broken --allowerasing

### (+) INSTALL
RUN echo "⭕ --- (+) Add packages ---"

#### DNF related contents
RUN dnf5 install -y --skip-broken --allowerasing fedora-gpg-keys \
    dnf-plugins-core etckeeper-dnf dnf-repo
#### Desktop Environment
RUN dnf5 install -y --skip-broken --allowerasing cosmic-app-library cosmic-applets cosmic-panel cosmic-workspaces cosmic-bg cosmic-comp cosmic-desktop cosmic-greeter cosmic-idle \
    cosmic-osd cosmic-session cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon greetd greetd-selinux cosmic-edit cosmic-icon-theme cosmic-launcher
#### BOINC
RUN dnf5 install -y --skip-broken --allowerasing boinc-client boinc-client-static boinc-manager
#### Utilities
RUN dnf5 install -y --skip-broken --allowerasing uutils-coreutils util-linux PackageKit-command-not-found
#### Development
RUN dnf5 install -y --skip-broken --allowerasing git gh \
    rustup cargo clippy \
    zed
#### Power Management
RUN dnf5 install -y --skip-broken --allowerasing tuned tuned-ppd tuned-utils-systemtap
#### Multimedia
RUN dnf5 install -y --skip-broken --allowerasing obs-studio obs-studio-libs \
    krita krita-libs \
    inkscape
#### Artificial Intelligence
RUN dnf5 install -y --skip-broken --allowerasing gemini-cli ollama
#### Compression
RUN dnf5 install -y --skip-broken --allowerasing zstd
#### Generic userland stuff
RUN dnf5 install -y --skip-broken --allowerasing neohtop \
    peazip \
    brave-browser brave-keyring \
    steam steam-devices
#### Networking
RUN dnf5 install -y --skip-broken --allowerasing hblock \
    tor \
    tailscale trayscale \
    mosh openssh \
    persepolis
#### High Performance Computing
RUN dnf5 install -y --skip-broken --allowerasing podman podman-docker \
    rocm cuda

# LINTING
#-Verify final image and contents
RUN bootc container lint --no-truncate
