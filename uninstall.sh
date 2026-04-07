#!/bin/bash
PROGRAM_PATH=$(readlink -f /proc/$(pgrep -f "AegisProxy" | head -1)/exe 2>/dev/null)
PROGRAM_DIR=$(dirname "$PROGRAM_PATH")
rm -rf "$PROGRAM_DIR/config" 2>/dev/null
rm -f "$PROGRAM_PATH" 2>/dev/null
sudo systemctl stop aegisproxy 2>/dev/null
sudo systemctl disable aegisproxy 2>/dev/null
sudo rm /etc/systemd/system/aegisproxy.service 2>/dev/null
sudo systemctl daemon-reload
echo "✅ 卸载完成"
