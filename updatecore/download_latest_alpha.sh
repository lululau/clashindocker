#!/bin/bash
set -ex
# 获取最新的版本号
version=$(curl -s -L https://kkgithub.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt)

# 拼接下载链接
url="https://kkgithub.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-amd64-${version}.gz"
# 下载文件
curl -LO $url --progress-bar

# 解压文件
gzip -d "mihomo-linux-amd64-${version}.gz"
mv "mihomo-linux-amd64-${version}" mihomo_alpha
chmod +x mihomo_alpha