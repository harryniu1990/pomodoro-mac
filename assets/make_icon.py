from PIL import Image, ImageDraw
import math

S = 1024
img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# 圆角背景（白底卡片感）
d.rounded_rectangle([40, 40, S-40, S-40], radius=220, fill=(255, 255, 255, 255))

# 番茄主体
cx, cy, r = S//2, S//2 + 90, 330
d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(232, 76, 61, 255))

# 高光
hl = 120
d.ellipse([cx-r+70, cy-r+80, cx-r+70+hl, cy-r+80+int(hl*0.75)], fill=(255, 255, 255, 90))

# 番茄蒂（绿色星形）
gx, gy = cx, cy - r + 10
d.ellipse([gx-95, gy-70, gx+95, gy+60], fill=(76, 175, 80, 255))
# 蒂的几片叶子
for ang in (-40, 0, 40):
    a = math.radians(ang - 90)
    x1 = gx + math.cos(a) * 60
    y1 = gy + math.sin(a) * 60 + 30
    x2 = gx + math.cos(a) * 160
    y2 = gy + math.sin(a) * 160 + 30
    d.line([(x1, y1), (x2, y2)], fill=(56, 142, 60, 255), width=42)

# 表盘指针（象征计时器）
d.line([(cx, cy), (cx, cy-200)], fill=(255, 255, 255, 255), width=30)
d.line([(cx, cy), (cx+140, cy+70)], fill=(255, 255, 255, 255), width=30)
d.ellipse([cx-28, cy-28, cx+28, cy+28], fill=(255, 255, 255, 255))

import sys
out = sys.argv[1] if len(sys.argv) > 1 else "icon_1024.png"
img.save(out)
print("icon saved:", out)
