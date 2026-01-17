#!/usr/bin/env fish

### Just copies over filesystem components

# Get
cd /tmp/
rm -rf /tmp/Fynelium-LX
mkdir -p /tmp/Fynelium-LX
git clone https://github.com/MrGrappleMan/Fynelium-LX.git /tmp/Fynelium-LX/
cd /tmp/Fynelium-LX/

# Copy-over
cp -r /tmp/Fynelium-LX/FSRoot/etc/* /etc/
cp -r /tmp/Fynelium-LX/FSRoot/var/* /var/
cp -r /tmp/Fynelium-LX/FSRoot/opt/* /opt/
##cp -r /tmp/Fynelium-LX/FSRoot/root/* /root/
