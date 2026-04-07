# 🛡️ AegisProxy - 智能域名防护系统

AegisProxy 是一款强大的域名防拦截系统

## 📦 一键安装

```bash
bash <(wget -qO- https://raw.githubusercontent.com/AegisProxyX/AegisProxy/main/install.sh)
```

或

## 🗑️ 一键卸载

```bash
bash <(wget -qO- https://raw.githubusercontent.com/AegisProxyX/AegisProxy/main/uninstall.sh)
```

运行后输入激活码 
进入配置向导：
输入后台管理端口（回车随机生成）
输入后台访问路径（回车随机生成），
配置完成后自动后台运行，开机自启动。

## ⚠️ 重要警告

**内部端口和 AegisProxy 对外端口不能相同，否则会导致端口冲突，两个服务都无法正常访问！**

### 原因

每个端口同一时间只能被一个程序占用。如果两边设置成同一个端口，两个程序会互相争抢，结果谁都别想用。

### 正确示例

| 角色 | 端口 | 说明 |
|------|------|------|
| 你的网站（内部端口） | `8000` | 网站实际运行的端口 |
| AegisProxy（对外端口） | `80` | 用户访问的端口 |

### 错误示例

| 角色 | 端口 | 结果 |
|------|------|------|
| 你的网站（内部端口） | `80` | ❌ 端口被占用，网站启动失败 |
| AegisProxy（对外端口） | `80` | ❌ 端口被占用，代理启动失败 |

### 一句话总结

**你的网站用 `8000`，AegisProxy 就用 `80`；你的网站用 `8080`，AegisProxy 就用 `80`。总之，两个数字不能一样！**
-----------------------



🔧 服务管理

systemctl status aegisproxy     # 查看状态

systemctl restart aegisproxy    # 重启服务

systemctl stop aegisproxy       # 停止服务

journalctl -u aegisproxy -f     # 查看日志


❓ 常见问题

问: 端口映射显示"未启动"？
答: 检查内部端口服务是否正常运行：curl 127.0.0.1:内部端口

问: 对外端口显示"被占用"？
答: 使用后台的「端口解除」功能释放端口，或更换端口。

问: 忘记登录密码？
答: 密码就是激活码，可在 config/config.json 中查看。

问: 程序意外关闭会自动重启吗？
答: 会，配置了自动重启，5秒内恢复。

📞 联系方式
Telegram: @QA222222



