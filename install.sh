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

# ========== 检测系统类型 ==========
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        OS=$(uname -s)
    fi
    echo -e "${GREEN}✅ 检测到系统: $OS${NC}"
}

# ========== 安装依赖（通用） ==========
install_deps() {
    echo -e "${YELLOW}🔍 检测并安装依赖...${NC}"
    
    # 检测包管理器并安装 lsof, wget, iptables
    local pkg_manager=""
    local install_cmd=""
    
    if command -v apt &> /dev/null; then
        pkg_manager="apt"
        install_cmd="apt update -qq && apt install -y"
    elif command -v yum &> /dev/null; then
        pkg_manager="yum"
        install_cmd="yum install -y"
    elif command -v dnf &> /dev/null; then
        pkg_manager="dnf"
        install_cmd="dnf install -y"
    elif command -v pacman &> /dev/null; then
        pkg_manager="pacman"
        install_cmd="pacman -S --noconfirm"
    elif command -v apk &> /dev/null; then
        pkg_manager="apk"
        install_cmd="apk add"
    elif command -v zypper &> /dev/null; then
        pkg_manager="zypper"
        install_cmd="zypper install -y"
    else
        echo -e "${RED}❌ 无法识别包管理器，请手动安装: lsof, wget, iptables${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}📦 使用包管理器: $pkg_manager${NC}"
    
    # 安装 lsof
    if ! command -v lsof &> /dev/null; then
        echo -e "${YELLOW}📦 安装 lsof...${NC}"
        eval "$install_cmd lsof" || echo -e "${YELLOW}⚠️ lsof 安装失败${NC}"
    fi
    
    # 安装 wget（如果没有）
    if ! command -v wget &> /dev/null; then
        echo -e "${YELLOW}📦 安装 wget...${NC}"
        eval "$install_cmd wget" || {
            # 如果 wget 安装失败，尝试用 curl
            if command -v curl &> /dev/null; then
                echo -e "${YELLOW}⚠️ 使用 curl 代替 wget${NC}"
                alias wget='curl -O'
            else
                echo -e "${RED}❌ 需要 wget 或 curl 来下载文件${NC}"
                return 1
            fi
        }
    fi
    
    # 安装 iptables
    if ! command -v iptables &> /dev/null; then
        echo -e "${YELLOW}📦 安装 iptables...${NC}"
        eval "$install_cmd iptables" || echo -e "${YELLOW}⚠️ iptables 安装失败${NC}"
    fi
    
    return 0
}

# ========== 下载文件（支持重试） ==========
download_file() {
    local url=$1
    local output=$2
    local retry=3
    
    for i in $(seq 1 $retry); do
        echo -e "${YELLOW}📥 下载尝试 $i/$retry...${NC}"
        if command -v wget &> /dev/null; then
            wget -O "$output" "$url" && return 0
        elif command -v curl &> /dev/null; then
            curl -L -o "$output" "$url" && return 0
        else
            echo -e "${RED}❌ 没有找到 wget 或 curl${NC}"
            return 1
        fi
        sleep 2
    done
    return 1
}

# ========== 创建启动脚本（通用，不依赖 systemd） ==========
create_start_script() {
    local start_script="/usr/local/bin/aegisproxy-start"
    
    cat > "$start_script" << 'EOF'
#!/bin/bash
# AegisProxy 启动脚本（兼容所有系统）

PROGRAM="/usr/local/aegisproxy/AegisProxy"
PIDFILE="/var/run/aegisproxy.pid"
LOGFILE="/var/log/aegisproxy.log"

start() {
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "AegisProxy 已经在运行"
        return 1
    fi
    echo "启动 AegisProxy..."
    nohup "$PROGRAM" >> "$LOGFILE" 2>&1 &
    echo $! > "$PIDFILE"
    echo "启动成功，PID: $(cat $PIDFILE)"
}

stop() {
    if [ -f "$PIDFILE" ]; then
        local pid=$(cat "$PIDFILE")
        if kill -0 $pid 2>/dev/null; then
            echo "停止 AegisProxy (PID: $pid)..."
            kill $pid
            sleep 2
            kill -9 $pid 2>/dev/null
            rm -f "$PIDFILE"
            echo "已停止"
        else
            echo "进程不存在"
            rm -f "$PIDFILE"
        fi
    else
        echo "PID 文件不存在"
    fi
}

status() {
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "AegisProxy 运行中，PID: $(cat $PIDFILE)"
    else
        echo "AegisProxy 未运行"
    fi
}

case "$1" in
    start) start ;;
    stop) stop ;;
    restart) stop; sleep 1; start ;;
    status) status ;;
    *) echo "用法: $0 {start|stop|restart|status}" ;;
esac
EOF

    chmod +x "$start_script"
    echo -e "${GREEN}✅ 创建启动脚本: $start_script${NC}"
}

# ========== 配置开机自启（通用） ==========
setup_autostart() {
   # echo -e "${YELLOW}${NC}"
   
    
    # 优先使用 systemd
    if command -v systemctl &> /dev/null; then
      #  echo -e "${GREEN}✅ 使用 systemd${NC}"
        cat > /etc/systemd/system/aegisproxy.service << EOF
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

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable aegisproxy
        systemctl start aegisproxy
        return 0
    fi
    
    # 使用 SysV init
    if [ -d "/etc/init.d" ]; then
       # echo -e "${GREEN}✅ 使用 SysV init${NC}"
        cat > /etc/init.d/aegisproxy << 'EOF'
#!/bin/sh
### BEGIN INIT INFO
# Provides:          aegisproxy
# Required-Start:    $network $remote_fs
# Required-Stop:     $network $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: AegisProxy Service
# Description:       AegisProxy Domain Protection System
### END INIT INFO

PROGRAM="/usr/local/aegisproxy/AegisProxy"
PIDFILE="/var/run/aegisproxy.pid"

start() {
    if [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        echo "AegisProxy already running"
        return 1
    fi
    echo "Starting AegisProxy..."
    nohup "$PROGRAM" > /dev/null 2>&1 &
    echo $! > "$PIDFILE"
    echo "Started"
}

stop() {
    if [ -f "$PIDFILE" ]; then
        kill $(cat "$PIDFILE")
        rm -f "$PIDFILE"
        echo "Stopped"
    fi
}

case "$1" in
    start) start ;;
    stop) stop ;;
    restart) stop; sleep 1; start ;;
    *) echo "Usage: $0 {start|stop|restart}" ;;
esac
EOF
        chmod +x /etc/init.d/aegisproxy
        update-rc.d aegisproxy defaults 2>/dev/null || chkconfig --add aegisproxy 2>/dev/null
        /etc/init.d/aegisproxy start
        return 0
    fi
    
    # 使用 crontab 保活（最后的方案）
    echo -e "${YELLOW}⚠️ 使用 crontab 保活机制${NC}"
    (crontab -l 2>/dev/null; echo "@reboot /usr/local/aegisproxy/AegisProxy > /dev/null 2>&1 &") | crontab -
    /usr/local/aegisproxy/AegisProxy > /dev/null 2>&1 &
    return 0
}

# ========== 主安装流程 ==========
detect_os
install_deps

echo -e "${GREEN}════════════════════════════════════════════${NC}"

# 创建安装目录
echo -e "${YELLOW}📁 创建安装目录...${NC}"
mkdir -p /usr/local/aegisproxy

# 下载程序
echo -e "${YELLOW}📥 正在下载 AegisProxy...${NC}"
if ! download_file "https://github.com/AegisProxyX/AegisProxy/releases/download/v1.0.0/AegisProxy" "/usr/local/aegisproxy/AegisProxy"; then
    echo -e "${RED}❌ 下载失败，请检查网络连接${NC}"
    exit 1
fi

# 添加执行权限
chmod +x /usr/local/aegisproxy/AegisProxy
ln -sf /usr/local/aegisproxy/AegisProxy /usr/local/bin/AegisProxy

# 创建启动脚本
create_start_script

# 运行配置向导（允许被杀死，因为后面会通过服务启动）
echo -e "${GREEN}✅ 下载完成，启动配置向导...${NC}"
/usr/local/aegisproxy/AegisProxy || true

# 配置开机自启
setup_autostart

# 检查运行状态
echo -e "${YELLOW}🔍 检查运行状态...${NC}"
sleep 2
if pgrep -f "AegisProxy" > /dev/null; then
    echo -e "${GREEN}✅ AegisProxy 运行中${NC}"
else
    echo -e "${RED}❌ AegisProxy 未运行${NC}"
fi
