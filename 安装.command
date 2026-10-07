#!/bin/bash
# 双击运行本脚本，自动安装 Pomodoro 并绕过系统的「身份不明开发者」拦截
cd "$(dirname "$0")"
clear
echo "=========================================="
echo "  🍅 Pomodoro 安装程序"
echo "=========================================="
echo ""

# 1. 找到同目录下的 Pomodoro.app
SRC=""
for cand in "Pomodoro.app" "./Pomodoro.app" "$(pwd)/Pomodoro.app"; do
  [ -d "$cand" ] && SRC="$cand" && break
done
if [ -z "$SRC" ]; then
  echo "❌ 没找到 Pomodoro.app，请把本脚本和 Pomodoro.app 放在同一目录。"
  read -n 1 -s -r -p "按任意键退出..."; exit 1
fi

# 2. 移除下载标记（quarantine），这一步解决「应用已损坏」
echo "① 清除隔离属性..."
xattr -cr "$SRC" 2>/dev/null

# 3. 复制到应用程序目录
echo "② 安装到 /Applications..."
if [ -d "/Applications/Pomodoro.app" ]; then
  rm -rf "/Applications/Pomodoro.app" 2>/dev/null || sudo rm -rf "/Applications/Pomodoro.app"
fi
if cp -R "$SRC" "/Applications/Pomodoro.app" 2>/dev/null; then
  :
else
  echo "   需要管理员权限，请输入开机密码（输入时不显示）:"
  sudo cp -R "$SRC" "/Applications/Pomodoro.app" || {
    echo "❌ 安装失败"; read -n 1 -s -r -p "按任意键退出..."; exit 1; }
fi

# 4. 装好后再次清理 + 签名
xattr -cr "/Applications/Pomodoro.app" 2>/dev/null
codesign -s - --force --deep /Applications/Pomodoro.app 2>/dev/null

echo "③ 启动 Pomodoro..."
open "/Applications/Pomodoro.app"

echo ""
echo "✅ 安装完成！"
echo "   如果仍弹出安全提示 → 系统设置 > 隐私与安全性 > 底部「仍要打开」"
echo ""
read -n 1 -s -r -p "按任意键关闭本窗口..."
echo ""
