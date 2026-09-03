# Containerfile

# LINK ESSENTIAL FILES
    FROM scratch AS ctx
    # 'ctx' means context
    # The FROM action here explicitly appends the 'ctx' name to the target=/ctx folder, is where that directory name actually comes from.
    # This path only exists for usage during build time, as a "portal" for your file into the image

# COPY BUILD IMAGE
  COPY /build-image/ / 
  # The COPY action copies the contents of the 'build-image' folder in the repo to the /ctx/ path in the image for build time
  # Whenever you want reference anything from /ctx/ from the Containerfile with RUN, always include '--mount=type=bind,from=ctx,source=/,target=/ctx'
  # Why not just link the repo root? This approach is cleaner.

# GET BASE IMAGE
    FROM ghcr.io/ublue-os/bazzite-gnome:testing
    # This is the image you want to begin modifying
    # Planned Base Image - fedora-bootc, it has a modern stack. Check the currently used one on your device with 'sudo bootc status'
    # We avoided Bazzite initialy, as it has unnecessary bloat and complicates the build process, but it has a stable and featureful base to work on
    # uBlue Image list: https://github.com/orgs/ublue-os/packages
    # reserved: quay.io/fedora/fedora-bootc

# IMMUTABLE /opt
    RUN rm -rf /opt && mkdir /opt
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

# DEBUG
  # To know of any errors that might occur, uncomment them if you need to for reference

# The below lists our that our repo to ctx copy was successful
#RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#    tree /ctx/
#RUN uname -a

# MODIFICATIONS TO IMAGE
    # You can modify the image by modifying the build-image.fish script and its subscripts
    # The RUN directive below handles "main.fish" execution as recommended and maps the usual UNIX file paths
    # avoid doing stuff from the Containerfile to avoid complexities, only minimal initialization
    # https://stackoverflow.com/questions/39223249/multiple-run-vs-single-chained-run-in-dockerfile-which-is-better
    # The parameters below doesn't seem to correlate with what actually occurs
    # However, multiple RUNs are preferred sometimes as they help with layer caching and build reproducibility
    # and more layers = more flexibility for future modifications + better resumeability support on unstable connections
    # At the cost of a larger image size, but it is worth it for the benefits
    # Despite correct shebang, forcefully call fish
    # Never make $home as /tmp, it is not the correct way to do it

# INSTALL FISH
    RUN dnf5 install -y --skip-broken --allowerasing --allowerasing --allow-downgrade fish

# Build image
    RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
        --mount=type=cache,dst=/var/cache \
        --mount=type=cache,dst=/var/log \
        --mount=type=tmpfs,dst=/tmp \
        fish /ctx/build-image.fish

# Linting
    RUN bootc container lint --no-truncate
    # Verify final image and contents for errors and warnings

# LABELS
    # Image has been built at this point
    # The labels below are used by artifacthub
    LABEL containers.bootc 1
    LABEL org.opencontainers.image.source="https://github.com/MrGrappleMan/aldehyde"
    LABEL org.opencontainers.image.description="Workstation image for performance, efficiency and productivity"
