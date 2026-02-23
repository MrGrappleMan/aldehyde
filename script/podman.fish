#!/usr/bin/env fish

# Honeygain
podman pull docker.io/honeygain/honeygain
podman run --rm honeygain/honeygain -tou-get
podman run -d --restart always --name honeygain_node \
  honeygain/honeygain -tou-accept \
  -email ACCOUNT_EMAIL -pass ACCOUNT_PASSWORD -device DEVICE_NAME

# Podman
CONTAINERS='aldy-packetshare aldy-earnfm honeygain repocket pawns-cli earnfm-client psclient'
sudo docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --include-stopped --include-restarting --revive-stopped --interval 300 $CONTAINERS
sudo docker update --restart=always --memory-swap=-1 --cpus=0.000 --cpu-quota=0 --pids-limit=-1 --cpu-rt-period=2000000 $(sudo docker ps -q -a)

# Remove all containers/pods, not images
#podman rm -af
#podman pod rm -af
