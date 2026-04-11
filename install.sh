#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}     AegisProxy 一键安装脚本${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"

# ========== 检测是否为 root ==========
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ 请使用 root 用户执行本安装脚本！${NC}"
    echo -e "${YELLOW}💡 请先执行以下命令切换到 root 用户：${NC}"
    echo -e "${GREEN}   su root${NC}"
    echo -e "${GREEN}   # 或${NC}"
    echo -e "${GREEN}   sudo -i${NC}"
    echo ""
    echo -e "${YELLOW}💡 切换后，重新运行安装命令即可${NC}"
    exit 1
fi

# ========== 检测并安装依赖 ==========
echo -e "${YELLOW}🔍 检测系统依赖...${NC}"

# 检测包管理器并安装 lsof
install_lsof() {
    if command -v apt &> /dev/null; then
        echo -e "${YELLOW}📦 检测到 apt，正在安装 lsof...${NC}"
        apt update -qq && apt install lsof -y
    elif command -v yum &> /dev/null; then
        echo -e "${YELLOW}📦 检测到 yum，正在安装 lsof...${NC}"
        yum install lsof -y
    elif command -v dnf &> /dev/null; then
        echo -e "${YELLOW}📦 检测到 dnf，正在安装 lsof...${NC}"
        dnf install lsof -y
    else
        echo -e "${RED}❌ 无法识别包管理器，请手动安装 lsof${NC}"
        return 1
    fi
    return 0
}

# 检查 lsof 是否已安装
if ! command -v lsof &> /dev/null; then
    echo -e "${YELLOW}⚠️ 未检测到 lsof，正在自动安装...${NC}"
    install_lsof
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ lsof 安装成功${NC}"
    else
        echo -e "${RED}❌ lsof 安装失败，部分功能可能异常${NC}"
    fi
else
    echo -e "${GREEN}✅ lsof 已安装${NC}"
fi

# 检查 iptables（一般系统自带，但确认一下）
if ! command -v iptables &> /dev/null; then
    echo -e "${YELLOW}⚠️ 未检测到 iptables，正在安装...${NC}"
    if command -v apt &> /dev/null; then
        apt install iptables -y
    elif command -v yum &> /dev/null; then
        yum install iptables -y
    elif command -v dnf &> /dev/null; then
        dnf install iptables -y
    fi
else
    echo -e "${GREEN}✅ iptables 已安装${NC}"
fi

echo -e "${GREEN}════════════════════════════════════════════${NC}"

# 创建安装目录
echo -e "${YELLOW}📁 创建安装目录...${NC}"
mkdir -p /usr/local/aegisproxy

# 下载程序到安装目录
echo -e "${YELLOW}📥 正在下载 AegisProxy...${NC}"
wget -O /usr/local/aegisproxy/AegisProxy https://github.com/AegisProxyX/AegisProxy/releases/download/v1.0.0/AegisProxy

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 下载失败，请检查网络连接${NC}"
    exit 1
fi

# 添加执行权限
chmod +x /usr/local/aegisproxy/AegisProxy

# 创建软链接到 PATH
ln -sf /usr/local/aegisproxy/AegisProxy /usr/local/bin/AegisProxy

# 运行配置向导
echo -e "${GREEN}✅ 下载完成，启动配置向导...${NC}"
/usr/local/aegisproxy/AegisProxy

echo -e "${GREEN}✅ 安装完成！${NC}"  
