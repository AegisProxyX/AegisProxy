#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🗑️ 正在卸载 AegisProxy...${NC}"

PROGRAM_PATH=$(readlink -f /proc/$(pgrep -f "AegisProxy" | head -1)/exe 2>/dev/null)
PROGRAM_DIR=$(dirname "$PROGRAM_PATH")

# 删除配置文件
rm -rf "$PROGRAM_DIR/config" 2>/dev/null

# 删除主程序
rm -f "$PROGRAM_PATH" 2>/dev/null

# 停止并删除服务
sudo systemctl stop aegisproxy 2>/dev/null
sudo systemctl disable aegisproxy 2>/dev/null
sudo rm /etc/systemd/system/aegisproxy.service 2>/dev/null
sudo systemctl daemon-reload

echo -e "${GREEN}✅ 卸载完成${NC}"
