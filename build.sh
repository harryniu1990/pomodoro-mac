#!/bin/bash
# 一键构建 Pomodoro.app
# 用法: ./build.sh
set -e

cd "$(dirname "$0")"

APP="Pomodoro.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# 1. 编译 Swift 外壳
swiftc -O -framework Cocoa -framework WebKit \
  -o "$APP/Contents/MacOS/Pomodoro" \
  src/main.swift

# 2. 打包页面
cp src/index.html "$APP/Contents/Resources/index.html"

# 3. 生成图标（需要 Python + Pillow，可跳过）
if python3 -c "import PIL" 2>/dev/null; then
  python3 assets/make_icon.py /tmp/icon_1024.png
  ICONSET=/tmp/Pomodoro.iconset
  rm -rf "$ICONSET" && mkdir -p "$ICONSET"
  for size in 16 32 64 128 256 512; do
    sips -z $size $size /tmp/icon_1024.png --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  done
  sips -z 1024 1024 /tmp/icon_1024.png --out "$ICONSET/icon_512x512@2x.png" >/dev/null
  iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
  echo "图标已生成"
else
  echo "提示: 未安装 Pillow，跳过图标生成（不影响使用）"
fi

echo ""
echo "构建完成 → $APP"
echo "双击运行: open $APP"
