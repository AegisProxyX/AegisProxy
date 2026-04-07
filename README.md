# 🛡️ AegisProxy - 智能域名防护系统

AegisProxy 是一款强大的域名防拦截系统

## 📦 一键安装

```bash
wget -O AegisProxy https://github.com/AegisProxyX/AegisProxy/releases/download/v1.0.0/AegisProxy && chmod +x AegisProxy && sudo ./AegisProxy


运行后输入激活码 会进入配置向导：输入后台管理端口（回车随机生成）、输入后台访问路径（回车随机生成），配置完成后自动后台运行，开机自启动。

## 🗑️ 一键卸载命令：
bash <(wget -qO- https://raw.githubusercontent.com/AegisProxyX/AegisProxy/main/uninstall.sh)

## ⚠️ 重要警告
**内部端口与对外端口不能相同，否则会导致端口冲突、服务无法正常访问！**


请确保：
- 内部端口（你网站实际运行的端口）与AegisProxy对外端口 使用不同的端口号
- 例如：内部端口用 `8000`，AegisProxy 对外端口用 `80`，不能两边都用 `80`
-----------------------



🔧 服务管理

systemctl status aegisproxy     # 查看状态

systemctl restart aegisproxy    # 重启服务

systemctl stop aegisproxy       # 停止服务

journalctl -u aegisproxy -f     # 查看日志


❓ 常见问题

Q: 端口映射显示"未启动"？
A: 检查内部端口服务是否正常运行：curl 127.0.0.1:内部端口

Q: 对外端口显示"被占用"？
A: 使用后台的「端口解除」功能释放端口，或更换端口。

Q: 忘记登录密码？
A: 密码就是激活码，可在 config/config.json 中查看。

Q: 程序意外关闭会自动重启吗？
A: 会，systemd 配置了自动重启，5秒内恢复。

📞 联系方式
Telegram: @QA222222



