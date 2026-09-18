# Containerfile

# Link essential files
    FROM scratch AS ctx
    # 'ctx' means context
    # The FROM action here explicitly appends the 'ctx' name to the target=/ctx folder, is where that directory name actually comes from.
    # This path only exists for usage during build time, as a "portal" for your file into the image

# Copy image build files
  COPY /build-image/ /
  # The COPY action copies the contents of the 'build-image' folder in the repo to the /ctx/ path in the image for build time
  # Whenever you want reference anything from /ctx/ from the Containerfile with RUN, always include '--mount=type=bind,from=ctx,source=/,target=/ctx'
  # Why not just link the repo root? This approach is cleaner.

# Derive from base image
    FROM ghcr.io/ublue-os/bluefin
    # This is the image you want to begin modifying
    # Planned Base Image - fedora-bootc, it has a modern stack. Check the currently used one on your device with 'sudo bootc status'
    # Bluefin has a stable and featureful base to work on, for now.
    # uBlue Image list: https://github.com/orgs/ublue-os/packages
    # reserved: quay.io/fedora/fedora-bootc

# Allow /opt declaration by image
    RUN rm -rf /opt && mkdir /opt
    # In some cases, /opt is symlinked to /var/opt, to allow changes in it by the user and allowing some programs to install themselves there
    # that are not integrated with the system image(when rpm-ostree layering is used). However for user-side mutations, we have to sacrifice this
    # path for bootc not being able to add packages to it during build time and it not carrying over to the final image. But, we want a single source of truth for /opt
    # so we create it as a real directory and not a symlink. The user can simply use distrobox to install those packages themselves.
    # Despite being not in the image, programs like Brave depend to be placed in /opt/ for proper functionality.

# Debug
    # To know of any errors that might occur, uncomment them if you need to for reference
    # The below lists our that our repo to ctx copy was successful
    #RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    #    tree /ctx/
    #RUN uname -a

# Guide to modifying the image
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

# Install fish prior true build
    RUN dnf5 install -y --skip-broken --allowerasing --allowerasing --allow-downgrade fish

# Build image mega script
    RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
        --mount=type=cache,dst=/var/cache \
        --mount=type=cache,dst=/var/log \
        --mount=type=tmpfs,dst=/tmp \
        fish /ctx/build-image.fish

# Linting
    RUN bootc container lint --no-truncate
    # Verify final image and contents for errors and warnings

# Labels
    # Image has been built at this point
    # The labels below are used by artifacthub
    LABEL containers.bootc 1
    LABEL org.opencontainers.image.source="https://github.com/MrGrappleMan/aldehyde"
    LABEL org.opencontainers.image.description="Workstation image for performance, efficiency and productivity"
