# Containerfile
## Are you a beginner and want to know how the creation of a bootc image actually works?
## Check out the comments below and correlate them with the repo's file structure

# LINK ESSENTIAL FILES
## 'ctx' means context
## The FROM action here explicitly appends the 'ctx' name to the target=/ctx folder, is where that directory name actually comes from.
## A new path made in root of the image being created, NOT the buildah image runner instance
FROM scratch AS ctx

## The COPY action "symlinks" the build-image folder from the repo to the /ctx/ path in the image.
## Whenever you want reference anything from /ctx/ from the Containerfile with RUN, always include '--mount=type=bind,from=ctx,source=/,target=/ctx'
## Why not just link the repo root? The approach is cleaner, feels less bloated.
COPY /build-image/ /

# GET BASE IMAGE
## This is the image you want to begin modifying
## Base Image - We use Bazzite GNOME's Testing branch, check the currently used one on your device with 'sudo bootc status'
## We did not use Bazzite GNOME DX because the pre-included tools are redundant and bloated we do not want to waste resources removing them.
## uBlue Image list: https://github.com/orgs/ublue-os/packages
FROM ghcr.io/ublue-os/bazzite-gnome:testing

# IMMUTABLE /opt
## In other images, /opt is symlinked to /var/opt, to allow changes in it by the user
## Some pkgs need this path to get installed into it
## However since it is symlinked to /var/, it is all useless as /var/ is wiped out after building and thus /var/opt is wiped out too
## And the user won't be able to install anything to it, there's no point in leaving it mutable. This made sense when rpm-ostree was used to layer packages.
## Thus, some of those needed /opt to be mutable
## Comment line below to allow modifications to it when user will be using the image, but its pointless - they can just use distrobox or other solutions
## It makes the /opt/ directory genuine and not just a symlink
## Brave and its keyring work best when it is inside /opt/ and is not a Flatpak
##
## Legacy OSTree systems symlink /opt -> /var/opt to allow runtime changes with apply-live or even layering packages on the user side.
## In a bootc build, this causes RPMs to install data into /var (that's /var/opt/) , which is
## discarded during deployment, leaving the application missing at on the user end.
##
## By forcing /opt to be a real directory, we ensure that Brave Browser and
## other /opt-resident packages are captured in the immutable image layers.
## host-side mutability is deferred to Distrobox/Containers.
RUN rm -rf /opt && mkdir /opt

# DEBUG
## To know of any errors that might occur, uncomment them if you need to for reference

## The below lists our that our repo to ctx copy was successful
#RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#    tree /ctx/
#RUN uname -a

# MODIFICATIONS TO IMAGE
## Make modifications to the image and install packages by modifying the build.fish script
## the below RUN directive handles "main.fish" execution as recommended while initializing the rest of familiar UNIX file paths
## avoid doing stuff from the Containerfile to avoid complexities, only minimal initialization
## https://stackoverflow.com/questions/39223249/multiple-run-vs-single-chained-run-in-dockerfile-which-is-better
## The parameters below doesn't seem to correlate with what actually occurs
## However, multiple RUNs are preferred sometimes as they help with layer caching and build reproducibility
## and more layers = more flexibility for future modifications + better resumeability support on unstable connections
## At the cost of a larger image size, but it is worth it for the benefits
## We explicitly call fish so correct interpreter is run, despite correct shebang
## Never make $home as /tmp, lots of problems will happen

## INSTALL FISH
RUN dnf5 install -y --skip-broken --allowerasing --allowerasing --allow-downgrade fish

## BUILD IMAGE
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    fish /ctx/build-image.fish

# LINTING
## Verify final image and contents
## You will be warned though if some /var/ contents are not empty
RUN bootc container lint --no-truncate

# LABELS
## Your image has been successfulyy built!
## Now we just append some tags here that can be derived by artifacthub
LABEL containers.bootc 1
LABEL org.opencontainers.image.source="https://github.com/MrGrappleMan/aldehyde-lx"
LABEL org.opencontainers.image.description="A workstation for performance"
