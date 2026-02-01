#!/usr/bin/env fish

# Force dracut to rebuild the initramfs for the specific CachyOS kernel version
RUN KERNEL_VERSION=$(ls /lib/modules | grep cachyos) && \
    dracut --force --kver $KERNEL_VERSION
