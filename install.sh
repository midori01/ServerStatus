#!/bin/bash
set -ex

WORKSPACE=/opt/ServerStatus
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}

sysArch() {
    uname=$(uname -m)
    if [[ "$uname" == *"armv8"* ]] || [[ "$uname" == "aarch64" ]]; then
        OS_ARCH="aarch64"
    else
        OS_ARCH="x86_64"
    fi    
}

latest_version=$(curl -m 10 -sL "https://api.github.com/repos/midori01/serverstatus/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
wget --no-check-certificate -qO "server-${OS_ARCH}-unknown-linux-musl.zip"  "https://github.com/midori01/serverstatus/releases/download/${latest_version}/server-${OS_ARCH}-unknown-linux-musl.zip"
wget --no-check-certificate -qO "client-${OS_ARCH}-unknown-linux-musl.zip"  "https://github.com/midori01/serverstatus/releases/download/${latest_version}/client-${OS_ARCH}-unknown-linux-musl.zip"
unzip -o "server-${OS_ARCH}-unknown-linux-musl.zip"
unzip -o "client-${OS_ARCH}-unknown-linux-musl.zip"
mv -v stat_server.service /etc/systemd/system/stat_server.service
mv -v stat_client.service /etc/systemd/system/stat_client.service
systemctl daemon-reload
systemctl start stat_server
systemctl start stat_client
systemctl enable stat_server
systemctl enable stat_client
