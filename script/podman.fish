#!/usr/bin/env fish

# Docker is not used because Podman has built in provisions that work better from the ground up,
# it is resource efficient, integrated into systemd, daemonless, rootless and less prone to breakages
# I have not used any docker removal steps as it is meant to be used in my bootc image where
# docker is not present at all, only the podman-docker package for compatibility
# Podman is built in a way that utilities like watchtower are not needed

# Units podman.service, podman.socket podman-auto-update.timer should be enabled

# ===================
# Pull images 
# ===================
echo "📦 Pulling latest images..."
podman pull docker.io/honeygain/honeygain \
            docker.io/iproyal/pawns-cli:latest \
            docker.io/earnfm/earnfm-client:latest \
            docker.io/packetstream/psclient:latest \
            \
            docker.io/thetorproject/snowflake-proxy:nightly

# PW - Password, TK - Token/Authentication key phrase
set -gx EMAIL "you@example.com" # Assumes the same email is used for all idle income sources
set -gx HNY_PASS "pass"
set -gx PWN_PASS "pass"
set -gx EFM_TK "token"
set -gx PSH_TK "token"
set -gx DEVICE_ID (hostname) # Use native hostname

# ===========================
# Create containers
# ===========================
# Format for each is,
# 1. Runner(always active, auto update label)
# 2. Container identity(container name, image used)
# 3. Arguments

# --- Honeygain ---
podman run -d --restart always --label "io.containers.autoupdate=image" \
  --name honeygain docker.io/honeygain/honeygain \
  -tou-accept -email $EMAIL -pass $HONEY_PASS -device $DEVICE_ID

podman run --rm honeygain/honeygain -tou-get
podman run -d --restart always --name honeygain_node \
  honeygain/honeygain -tou-accept \
  -email ACCOUNT_EMAIL -pass ACCOUNT_PASSWORD -device DEVICE_ID

# --- Pawns.app ---
podman run -d --restart always --label "io.containers.autoupdate=image" \
  --name pawns-cli docker.io/iproyal/pawns-cli:latest \
  -email=$EMAIL -password=$PAWNS_PASS -device-name=$DEVICE_ID -device-id=$DEVICE_ID -accept-tos

# --- EarnFM ---
podman run -d --restart always --label "io.containers.autoupdate=image" \
  --name earnfm docker.io/earnfm/earnfm-client:latest \
  -e EARNFM_TOKEN="$EFM_TK"

# --- PacketStream ---
podman run -d --restart always --label "io.containers.autoupdate=image" \
  --name psclient docker.io/packetstream/psclient:latest \
  -e CID="$PSH_TK"

# --- Tor Snowflake Proxy ---
podman run -d --restart always --label "io.containers.autoupdate=image" \
  --name snowflake-proxy docker.io/thetorproject/snowflake-proxy:nightly \
  -ephemeral-ports-range "30000:60000" -allow-non-tls-relay -allow-proxying-to-private-addresses -summary-interval 1h -metrics --net host

# Remove all containers/pods, not images - Emergency step
#podman rm -af
#podman pod rm -af
