#!/bin/bash

source /etc/environment

if [ "${NODE_ROLE}" != "proxy" ]; then
    exit 0
fi

export ETCDCTL_PEERS="http://$ETCDCTL_PEERS_ENDPOINT"

if [ "$(etcdctl get images-proxy-bootstrapped)" == "true" ]; then
    echo "proxy-tier images already bootstrapped, skipping"
    exit 0
fi
etcdctl set images-proxy-bootstrapped true

etcdctl set /images/capcom       "behance/capcom:latest"
etcdctl set /images/capcom2      "behance/capcom:latest"
etcdctl set /images/proxy        "nginx:1.9.5"

# pull down images serially to avoid a FS layer clobbering bug in docker 1.6.x
docker pull behance/mesos-proxy-setup
docker pull $(etcdctl get /images/capcom)
docker pull $(etcdctl get /images/capcom2)
docker pull $(etcdctl get /images/proxy)
