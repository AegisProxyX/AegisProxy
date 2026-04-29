#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🗑️ 正在卸载 AegisProxy...${NC}"

# 停止并删除服务
systemctl stop aegisproxy 2>/dev/null
systemctl disable aegisproxy 2>/dev/null
rm /etc/systemd/system/aegisproxy.service 2>/dev/null
systemctl daemon-reload

# 删除主程序和配置目录
rm -rf /usr/local/aegisproxy 2>/dev/null

# 删除软链接

rm -f /usr/local/aegisproxy/AegisProxy /usr/local/aegisproxy/config/setup.json 2>/dev/null

echo -e "${GREEN}✅ 卸载完成${NC}"
