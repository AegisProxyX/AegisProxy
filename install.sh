# 原来的：
/usr/local/aegisproxy/AegisProxy

echo -e "${GREEN}✅ 安装完成！${NC}"

# 改成：
nohup /usr/local/aegisproxy/AegisProxy > /usr/local/aegisproxy/aegis.log 2>&1 &

sleep 2

if pgrep -f "AegisProxy" > /dev/null; then
    echo -e "${GREEN}✅ AegisProxy 已在后台运行${NC}"
else
    echo -e "${RED}❌ 启动失败${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 安装完成！${NC}"
