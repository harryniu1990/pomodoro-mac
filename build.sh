#!/bin/bash
# 一键构建 Pomodoro.app
# 用法: ./build.sh
set -e

cd "$(dirname "$0")"

APP="Pomodoro.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

# 1. 编译 Swift 外壳（默认构建 arm64 + x86_64 通用二进制）
mkdir -p /tmp/pomodoro-build
if swiftc -O -target x86_64-apple-macosx11.0 -framework Cocoa -framework WebKit \
     -o /tmp/pomodoro-build/pom_x86 src/main.swift 2>/tmp/pomodoro-build/x86.log; then
  swiftc -O -framework Cocoa -framework WebKit \
    -o /tmp/pomodoro-build/pom_arm src/main.swift
  lipo -create -output "$APP/Contents/MacOS/Pomodoro" \
    /tmp/pomodoro-build/pom_arm /tmp/pomodoro-build/pom_x86
  echo "已构建通用二进制 (Apple Silicon + Intel)"
else
  echo "提示: Intel 架构编译不可用，仅构建本机架构"
  swiftc -O -framework Cocoa -framework WebKit \
    -o "$APP/Contents/MacOS/Pomodoro" src/main.swift
fi

# 2. 打包页面
cp src/index.html "$APP/Contents/Resources/index.html"

# 2.5 生成 Info.plist（必须有！缺了它应用没有图标、没有 bundle 标识）
cat > "$APP/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleName</key>
	<string>番茄钟</string>
	<key>CFBundleDisplayName</key>
	<string>番茄钟</string>
	<key>CFBundleExecutable</key>
	<string>Pomodoro</string>
	<key>CFBundleIdentifier</key>
	<string>com.local.pomodoro</string>
	<key>CFBundleVersion</key>
	<string>1.0.2</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0.2</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>LSMinimumSystemVersion</key>
	<string>11.0</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
PLIST
echo "Info.plist 已生成"

# 3. 生成图标（需要 Python + Pillow，找不到就跳过）
PY=""
for cand in python3 "$HOME/.workbuddy/binaries/python/envs/default/bin/python3" /usr/bin/python3; do
  if command -v "$cand" >/dev/null 2>&1 && "$cand" -c "import PIL" 2>/dev/null; then
    PY="$cand"; break
  fi
done

if [ -n "$PY" ]; then
  "$PY" assets/make_icon.py /tmp/icon_1024.png >/dev/null
  ICONSET=/tmp/Pomodoro.iconset
  rm -rf "$ICONSET" && mkdir -p "$ICONSET"
  for size in 16 32 64 128 256 512; do
    sips -z $size $size /tmp/icon_1024.png --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
  done
  sips -z 1024 1024 /tmp/icon_1024.png --out "$ICONSET/icon_512x512@2x.png" >/dev/null
  iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
  echo "图标已生成"
else
  # 兜底：assets 里有现成 PNG 就直接用，保证一定有图标
  if [ -f assets/icon_1024.png ]; then
    echo "提示: 未安装 Pillow，改用 assets/icon_1024.png"
    ICONSET=/tmp/Pomodoro.iconset
    rm -rf "$ICONSET" && mkdir -p "$ICONSET"
    for size in 16 32 64 128 256 512; do
      sips -z $size $size assets/icon_1024.png --out "$ICONSET/icon_${size}x${size}.png" >/dev/null
    done
    sips -z 1024 1024 assets/icon_1024.png --out "$ICONSET/icon_512x512@2x.png" >/dev/null
    iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
  else
    echo "提示: 无图标可用"
  fi
fi

# 4. Ad-hoc 签名（无开发者证书也能签，避免被系统判定为「已损坏」）
if codesign -s - --force --deep --timestamp=none "$APP" 2>/dev/null; then
  echo "已 ad-hoc 签名"
else
  echo "提示: 签名失败（不影响本机使用，分发时建议重试）"
fi

echo ""
echo "构建完成 → $APP"
echo "双击运行: open $APP"
