# 🛡️ AegisProxy - 智能域名防护系统

AegisProxy 是一款强大的域名防拦截系统

## 📦 一键安装命令：wget -O AegisProxy https://github.com/AegisProxyX/AegisProxy/releases/download/v1.0.0/AegisProxy && chmod +x AegisProxy && sudo ./AegisProxy


运行后输入激活码 会进入配置向导：输入后台管理端口（回车随机生成）、输入后台访问路径（回车随机生成），配置完成后自动后台运行，开机自启动。

🗑️ 一键卸载命令：PROGRAM_PATH=$(readlink -f /proc/$(pgrep -f "AegisProxy" | head -1)/exe 2>/dev/null); PROGRAM_DIR=$(dirname "$PROGRAM_PATH"); rm -rf "$PROGRAM_DIR/config" 2>/dev/null; rm -f "$PROGRAM_PATH" 2>/dev/null; sudo systemctl stop aegisproxy 2>/dev/null; sudo systemctl disable aegisproxy 2>/dev/null; sudo rm /etc/systemd/system/aegisproxy.service 2>/dev/null; sudo systemctl daemon-reload; echo "✅ 卸载完成"


📖 使用说明
第一步：登录后台
安装完成后会显示后台地址，用浏览器打开，输入激活码登录。

第二步：添加端口映射
点击左侧菜单「端口映射」

点击「创建映射」

填写内部端口（你网站实际运行的端口）和对外端口（用户访问的端口）

点击「创建映射」

添加后内部端口会自动禁止外部直接访问。

第三步：配置爬虫白名单（可选）
点击「爬虫白名单」，每行添加一个爬虫 UA，如：BaiduSpider、Googlebot、bingbot

第四步：配置 IP 白名单（可选）
点击「IP白名单」，每行一个 IP 地址，白名单内的 IP 将绕过所有拦截规则。

第五步：开启二级域名重定向（可选）
点击「重定向设置」，配置域名格式。使用前需确保域名已配置泛解析（*.你的域名.com）

## ⚠️ 重要警告

**内部端口与对外端口不能相同，否则会导致端口冲突、服务无法正常访问！**

请确保：
- 内部端口（你网站实际运行的端口）与AegisProxy对外端口 使用不同的端口号
- 例如：内部端口用 `8000`，AegisProxy 对外端口用 `80`，不能两边都用 `80`



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
