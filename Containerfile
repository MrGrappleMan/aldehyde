# Allow build scripts to be referenced w/o being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image - Bazzite-DX GNOME, check current with 'sudo bootc status'
FROM ghcr.io/ublue-os/bazzite-dx-gnome:latest
# uBlue Image list: https://github.com/orgs/ublue-os/packages

### MUTABLE /opt
# Some bootable images, like Fedora, have /opt symlinked to /var/opt, to allow changes in it
# Kept mutable to allow some pkgs to function that rely on this path
# Uncomment line below to lock modifications to it, not recommended
#RUN rm -rf /opt && mkdir /opt

### MODIFICATIONS
# make modifications desired in your image and install packages by modifying the build.sh script
# the below RUN directive handles "build.sh" execution as recommended
# avoid doing stuff from the Containerfile to avoid complexities, only minimal initialization

RUN dnf5 install -y fish && dnf clean all

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.fish
    
### LINTING
## Verify final image and contents
RUN bootc container lint
