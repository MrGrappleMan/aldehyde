# Are you a beginner and want to know how the creation of a bootc image actually works?
# See the comments below and correlate them with the repo's file structure

# Context stage: The repo is the source of truth
# 'ctx' means context
# FROM in here explicitly connects the 'ctx' name to the target=/ctx folder, is where that directory name actually comes from.
FROM scratch AS ctx

# COPY in this file serves as a 'bridge' from the repo's root and the image. The first string references the repo root, the other is the image /ctx/
# All the files in the repo will end up in /ctx/ when seen from inside the image instance, look at the '..AS ctx' line above, thats why it is /ctx/
# Whenever you want reference anything from /ctx/ from the Containerfile with RUN, always include '--mount=type=bind,from=ctx,source=/,target=/ctx'
COPY / /

# This is the image you want to begin modifying
# Base Image - We use Bazzite-DX GNOME, check the currently used one on your device with 'sudo bootc status'
FROM ghcr.io/ublue-os/bazzite-dx-gnome:latest
# uBlue Image list: https://github.com/orgs/ublue-os/packages

LABEL containers.bootc 1
LABEL org.opencontainers.image.source="https://github.com/MrGrappleMan/aldehyde-lx"
LABEL org.opencontainers.image.description="Rust-centric COSMIC Desktop on Bootc"

### IMMUTABLE /opt
# In other images, /opt is symlinked to /var/opt, to allow changes in it by the user
# Some pkgs need this path to get installed into it
# However since it is symlinked to /var/, it is all useless as /var/ is wiped out after building and thus /var/opt is wiped out too
# And the user won't be able to install anything to it, there's no point in leaving it mutable. This made sense when rpm-ostree was used to layer packages.
# Thus, some of those needed /opt to be mutable
# Comment line below to allow modifications to it when user will be using the image, but its pointless - they can just use distrobox or other solutions
# It makes the /opt/ directory genuine and not just a symlink
# Brave and its keyring work best when it is inside /opt/ and is not a Flatpak
#
# Legacy OSTree systems symlink /opt -> /var/opt to allow runtime changes with apply-live or even layering packages on the user side.
# In a bootc build, this causes RPMs to install data into /var (that's /var/opt/) , which is
# discarded during deployment, leaving the application missing at on the user end.
#
# By forcing /opt to be a real directory, we ensure that Brave Browser and
# other /opt-resident packages are captured in the immutable image layers.
# host-side mutability is deferred to Distrobox/Containers.

RUN rm -rf /opt && mkdir /opt

### INFO
# To know of any errors that might occur

# List our that our repo to ctx copy was successful
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    tree /ctx/
RUN uname -a

### MODIFICATIONS
# Make modifications to the image and install packages by modifying the build.fish script
# the below RUN directive handles "build.fish" execution as recommended while initializing the rest of familiar UNIX file paths
# avoid doing stuff from the Containerfile to avoid complexities, only minimal initialization

RUN dnf5 install -y fish

# Explicitly call fish so correct interpreter is run, despite correct shebang
# Never make $Home as /tmp, lots of problems in fish will happen
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    fish /ctx/build.fish

### LINTING
## Verify final image and contents
RUN bootc container lint --no-truncate
