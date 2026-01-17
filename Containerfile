# Allow build scripts to be referenced w/o being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image - Bazzite-DX GNOME, check current with 'sudo bootc status'
FROM ghcr.io/ublue-os/bazzite-dx-gnome:latest
# uBlue Image list: https://github.com/orgs/ublue-os/packages

### MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome-canary, docker-desktop.
#RUN rm -rf /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

# Systemd
RUN systemctl enable bootc-fetch-apply-updates.timer uupd.timer
RUN systemctl mask rpm-ostreed-automatic.service rpm-ostreed-automatic.timer rpm-ostree-countme.service rpm-ostree-countme.timer

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh
    
### LINTING
## Verify final image and contents
RUN bootc container lint
