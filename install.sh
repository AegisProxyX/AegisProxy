#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}     AegisProxy 一键安装脚本${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"

# 创建安装目录
echo -e "${YELLOW}📁 创建安装目录...${NC}"
sudo mkdir -p /usr/local/aegisproxy

# 下载程序到安装目录
echo -e "${YELLOW}📥 正在下载 AegisProxy...${NC}"
sudo wget -O /usr/local/aegisproxy/AegisProxy https://github.com/AegisProxyX/AegisProxy/releases/download/v1.0.0/AegisProxy

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 下载失败，请检查网络连接${NC}"
    exit 1
fi

# 添加执行权限
sudo chmod +x /usr/local/aegisproxy/AegisProxy

# 创建软链接到 PATH
sudo ln -sf /usr/local/aegisproxy/AegisProxy /usr/local/bin/AegisProxy

# 运行配置向导
echo -e "${GREEN}✅ 下载完成，启动配置向导...${NC}"
sudo /usr/local/aegisproxy/AegisProxy

echo -e "${GREEN}✅ 安装完成！${NC}"
