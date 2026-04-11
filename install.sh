#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

MAIN_URL="https://github.com/AegisProxyX/AegisProxy/releases/download/v1.0.0/AegisProxy"

echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}           AegisProxy 一键安装脚本${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ 请使用 root 用户执行${NC}"
    exit 1
fi

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        OS=$(uname -s)
    fi
    echo -e "${GREEN}✅ 检测系统: $OS${NC}"
}

install_deps() {
    echo -e "${YELLOW}🔍 检查依赖...${NC}"

    if command -v apt &> /dev/null; then
        apt update -qq
        apt install -y lsof wget iptables >/dev/null 2>&1
    elif command -v yum &> /dev/null; then
        yum install -y lsof wget iptables >/dev/null 2>&1
    elif command -v dnf &> /dev/null; then
        dnf install -y lsof wget iptables >/dev/null 2>&1
    elif command -v pacman &> /dev/null; then
        pacman -S --noconfirm lsof wget iptables >/dev/null 2>&1
    elif command -v apk &> /dev/null; then
        apk add lsof wget iptables >/dev/null 2>&1
    elif command -v zypper &> /dev/null; then
        zypper install -y lsof wget iptables >/dev/null 2>&1
    else
        echo -e "${RED}❌ 不支持当前系统${NC}"
        exit 1
    fi
}

download_file() {
    local output=$1
    local MIRRORS=(
        "$MAIN_URL"
        "https://ghproxy.net/$MAIN_URL"
    )

    for mirror in "${MIRRORS[@]}"; do
        echo -e "${BLUE}🔗 下载: $mirror${NC}"
        for i in 1 2 3; do
            echo -e "${YELLOW}  重试 $i/3${NC}"
            if command -v wget &>/dev/null; then
                wget -q --timeout=8 -O "$output" "$mirror" 2>/dev/null
            elif command -v curl &>/dev/null; then
                curl -sL --connect-timeout 8 -o "$output" "$mirror" 2>/dev/null
            fi
            [ -s "$output" ] && return 0
            sleep 1
        done
    done
    echo -e "${RED}❌ 下载失败${NC}"
    exit 1
}

create_start_script() {
cat >/usr/local/bin/aegisproxy-start <<'EOF'
#!/bin/bash
PROGRAM="/usr/local/aegisproxy/AegisProxy"
PIDFILE="/var/run/aegisproxy.pid"
LOGFILE="/var/log/aegisproxy.log"

start() {
  [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null && echo "已运行" && return
  echo "启动中..."
  nohup "$PROGRAM" >>"$LOGFILE" 2>&1 &
  echo $! >"$PIDFILE"
  echo "启动成功 PID: $(cat $PIDFILE)"
}

stop() {
  [ -f "$PIDFILE" ] || { echo "未运行"; return; }
  kill $(cat "$PIDFILE") 2>/dev/null
  rm -f "$PIDFILE"
  echo "已停止"
}

status() {
  [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null && echo "运行中" && return
  echo "未运行"
}

case "$1" in
  start) start ;;
  stop) stop ;;
  restart) stop; sleep 1; start ;;
  status) status ;;
  *) echo "用法: $0 {start|stop|restart|status}" ;;
esac
EOF
chmod +x /usr/local/bin/aegisproxy-start
}

setup_autostart() {
echo -e "${YELLOW}🚀 设置开机自启${NC}"

if command -v systemctl &>/dev/null; then
cat >/etc/systemd/system/aegisproxy.service <<EOF
[Unit]
Description=AegisProxy
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
return
fi

if [ -d /etc/init.d ]; then
cat >/etc/init.d/aegisproxy <<'EOF'
#!/bin/sh
PROGRAM="/usr/local/aegisproxy/AegisProxy"
PIDFILE="/var/run/aegisproxy.pid"

start() {
  [ -f "$PIDFILE" ] && kill -0 $(cat "$PIDFILE") 2>/dev/null && return
  nohup "$PROGRAM" >/dev/null 2>&1 &
  echo $! >"$PIDFILE"
}

stop() {
  [ -f "$PIDFILE" ] || return
  kill $(cat "$PIDFILE") 2>/dev/null
  rm -f "$PIDFILE"
}

case "$1" in
  start) start ;;
  stop) stop ;;
  restart) stop; sleep 1; start ;;
esac
EOF
chmod +x /etc/init.d/aegisproxy
update-rc.d aegisproxy defaults 2>/dev/null || chkconfig --add aegisproxy 2>/dev/null
/etc/init.d/aegisproxy start
return
fi

(crontab -l 2>/dev/null; echo "@reboot /usr/local/aegisproxy/AegisProxy >/dev/null 2>&1 &") | crontab -
/usr/local/aegisproxy/AegisProxy >/dev/null 2>&1 &
}

# ==================== 主流程 ====================
detect_os
install_deps

echo -e "${GREEN}════════════════════════════════════════════${NC}"

mkdir -p /usr/local/aegisproxy
download_file "/usr/local/aegisproxy/AegisProxy"

chmod +x /usr/local/aegisproxy/AegisProxy
ln -sf /usr/local/aegisproxy/AegisProxy /usr/local/bin/AegisProxy

create_start_script

echo -e "${GREEN}✅ 启动配置向导${NC}"
/usr/local/aegisproxy/AegisProxy 2>/dev/null || true

setup_autostart

echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ 安装完成${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${YELLOW}管理命令${NC}"
echo -e "  启动: aegisproxy-start start"
echo -e "  停止: aegisproxy-start stop"
echo -e "  状态: aegisproxy-start status"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
