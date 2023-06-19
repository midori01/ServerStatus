#!/bin/bash
set -ex
if [[ $EUID -ne 0 ]]; then
  echo "请切换到 root 用户后再运行脚本"
  exit 1
fi
if ! command -v wget &> /dev/null; then
  echo "wget 未安装，请安装后再运行脚本"
  exit 1
fi
if ! command -v unzip &> /dev/null; then
  echo "unzip 未安装，请安装后再运行脚本"
  exit 1
fi
if [[ "$(uname -m)" == "x86_64" ]]; then
  OS_ARCH="x86_64"
elif [[ "$(uname -m)" == "aarch64" ]]; then
  OS_ARCH="aarch64"
else
  echo "$(uname -m) 架构不支持"
  exit 1
fi
WORKSPACE=/opt/ServerStatus
latest_version=$(curl -m 10 -sL "https://api.github.com/repos/midori01/serverstatus/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
uninstall() {
  systemctl stop stat_server.service
  systemctl disable stat_server.service
  rm -f /etc/systemd/system/stat_server.service
  rm -f ${WORKSPACE}
  echo "ServerStatus-Server 已卸载"
}
update() {
  rm -f ${WORKSPACE}/stat_server
  mkdir -p ${WORKSPACE}/update
  cd ${WORKSPACE}/update
  wget --no-check-certificate -qO "server-${OS_ARCH}-unknown-linux-musl.zip"  "https://github.com/midori01/serverstatus/releases/download/${latest_version}/server-${OS_ARCH}-unknown-linux-musl.zip"
  unzip -o "server-${OS_ARCH}-unknown-linux-musl.zip"
  mv stat_server ${WORKSPACE}/stat_server
  rm -r ${WORKSPACE}/update
  systemctl restart stat_server.service
  echo "ServerStatus-Server 已更新"
}
if [[ $1 == "uninstall" ]]; then
  uninstall
  exit 0
fi
if [[ $1 == "update" ]]; then
  update
  exit 0
fi
mkdir -p ${WORKSPACE}
cd ${WORKSPACE}
wget --no-check-certificate -qO "server-${OS_ARCH}-unknown-linux-musl.zip"  "https://github.com/midori01/serverstatus/releases/download/${latest_version}/server-${OS_ARCH}-unknown-linux-musl.zip"
unzip -o "server-${OS_ARCH}-unknown-linux-musl.zip"
mv -v stat_server.service /etc/systemd/system/stat_server.service
rm -f server-${OS_ARCH}-unknown-linux-musl.zip
systemctl daemon-reload
systemctl start stat_server.service
systemctl enable stat_server.service
echo "ServerStatus-Server 安装成功"
