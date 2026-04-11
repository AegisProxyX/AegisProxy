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
    exit 1
fi

# ========== 停止旧服务 ==========
echo -e "${YELLOW}🛑 停止旧服务...${NC}"
systemctl stop aegisproxy 2>/dev/null
pkill -f AegisProxy 2>/dev/null
sleep 1

# ========== 检测并安装依赖 ==========
echo -e "${YELLOW}🔍 检测系统依赖...${NC}"

install_lsof() {
    if command -v apt &> /dev/null; then
        apt update -qq && apt install lsof -y
    elif command -v yum &> /dev/null; then
        yum install lsof -y
    elif command -v dnf &> /dev/null; then
        dnf install lsof -y
    else
        echo -e "${RED}❌ 无法识别包管理器，请手动安装 lsof${NC}"
        return 1
    fi
    return 0
}

if ! command -v lsof &> /dev/null; then
    install_lsof
fi

# ========== 创建目录 ==========
echo -e "${YELLOW}📁 创建安装目录...${NC}"
mkdir -p /usr/local/aegisproxy/config
chmod 755 /usr/local/aegisproxy

# ========== 下载程序 ==========
echo -e "${YELLOW}📥 正在下载 AegisProxy...${NC}"

# 支持多个下载源
DOWNLOAD_SUCCESS=false
for URL in \
    "https://github.com/AegisProxyX/AegisProxy/releases/download/v1.0.0/AegisProxy" \
    "https://mirror.example.com/AegisProxy" \
    ; do
    echo -e "   尝试从 $URL 下载..."
    wget -q --show-progress -O /usr/local/aegisproxy/AegisProxy "$URL"
    if [ $? -eq 0 ] && [ -s /usr/local/aegisproxy/AegisProxy ]; then
        DOWNLOAD_SUCCESS=true
        break
    fi
done

if [ "$DOWNLOAD_SUCCESS" = false ]; then
    echo -e "${RED}❌ 下载失败，请检查网络连接${NC}"
    exit 1
fi

# 添加执行权限
chmod +x /usr/local/aegisproxy/AegisProxy
ln -sf /usr/local/aegisproxy/AegisProxy /usr/local/bin/AegisProxy

echo -e "${GREEN}✅ 下载完成${NC}"

# ========== 直接创建 systemd 服务（不依赖程序内部函数）==========
echo -e "${YELLOW}🚀 创建 systemd 服务...${NC}"

cat > /etc/systemd/system/aegisproxy.service << 'EOF'
[Unit]
Description=AegisProxy Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/usr/local/aegisproxy
ExecStart=/usr/local/aegisproxy/AegisProxy
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable aegisproxy

echo -e "${GREEN}✅ systemd 服务创建成功${NC}"

# ========== 首次配置（使用 expect 或后台运行 + 配置文件）==========
echo -e "${YELLOW}🔧 首次配置...${NC}"

# 检查是否已有配置文件
if [ ! -f /usr/local/aegisproxy/config/setup.json ]; then
    echo -e "${YELLOW}⚙️ 检测到首次安装，请按照提示完成配置...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 前台运行程序进行配置，配置完成后程序会自动退出
    /usr/local/aegisproxy/AegisProxy
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

# ========== 启动服务 ==========
echo -e "${YELLOW}🚀 启动 AegisProxy 服务...${NC}"
systemctl start aegisproxy
sleep 2

# 检查服务状态
if systemctl is-active --quiet aegisproxy; then
    echo -e "${GREEN}✅ AegisProxy 服务已启动${NC}"
    
    # 获取后台地址
    sleep 1
    if [ -f /usr/local/aegisproxy/config/setup.json ]; then
        ADMIN_PORT=$(grep -o '"admin_port":[0-9]*' /usr/local/aegisproxy/config/setup.json | cut -d: -f2)
        ADMIN_PATH=$(grep -o '"admin_path":"[^"]*"' /usr/local/aegisproxy/config/setup.json | cut -d'"' -f4)
        
        # 获取服务器IP
        SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "服务器IP")
        
        echo -e ""
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
        echo -e "${GREEN}     🎉 AegisProxy 安装成功！${NC}"
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
        echo -e "${YELLOW}📋 访问信息：${NC}"
        echo -e "   后台地址: ${GREEN}http://${SERVER_IP}:${ADMIN_PORT}${ADMIN_PATH}${NC}"
        echo -e "   激活码:   ${GREEN}请查看 /usr/local/aegisproxy/config/config.json${NC}"
        echo -e ""
        echo -e "${YELLOW}📌 常用命令：${NC}"
        echo -e "   查看状态: ${GREEN}systemctl status aegisproxy${NC}"
        echo -e "   查看日志: ${GREEN}journalctl -u aegisproxy -f${NC}"
        echo -e "   重启服务: ${GREEN}systemctl restart aegisproxy${NC}"
        echo -e "   停止服务: ${GREEN}systemctl stop aegisproxy${NC}"
        echo -e "${GREEN}════════════════════════════════════════════${NC}"
    fi
else
    echo -e "${RED}❌ 服务启动失败，查看日志：${NC}"
    journalctl -u aegisproxy -n 20 --no-pager
    exit 1
fi
