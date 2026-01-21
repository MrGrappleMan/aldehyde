#!/bin/env fish

# Docker
# !`Setup----------
for cpkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker container runc; do sudo apt-fast remove $cpkg; done
cd /tmp/
curl -fsSL https://test.docker.com -o dck.sh
sudo sh dck.sh
# !`Final----------
CONTAINERS='mgmpsclient mgmearnfm-client honeygain repocket pawns-cli earnfm-client psclient'
sudo docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --cleanup --include-stopped --include-restarting --revive-stopped --interval 300 $CONTAINERS
sudo docker update --restart=always --memory-swap=-1 --cpus=0.000 --cpu-quota=0 --pids-limit=-1 --cpu-rt-period=2000000 $(sudo docker ps -q -a)
# !`Remove all(For emergencies)----------
sudo docker rm $(sudo docker ps -q -a) -f

