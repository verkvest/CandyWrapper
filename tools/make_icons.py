#!/usr/bin/env python3
"""Generate original Liltkin launcher icons.

Drawn in-repo from a 32x32 pixel grid. Not derived from the Godot logo
or from the upstream picon.
"""
import math
import os

from PIL import Image

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "branding"))

CREAM = (255, 248, 214, 255)
CREAM_DARK = (244, 214, 150, 255)
ORANGE = (254, 157, 22, 255)
BROWN = (116, 49, 1, 255)
INK = (42, 24, 12, 255)
BLUSH = (255, 196, 140, 255)


def _cell_color(x, y, n=32):
    fx = x - (n - 1) / 2.0
    fy = y - (n - 1) / 2.0
    r = math.hypot(fx, fy)
    # Keep the mark inside the adaptive-icon safe zone.
    if r > 14.6:
        return None
    ang = math.atan2(fy, fx)
    # Outer disc.
    if r > 13.15:
        return INK
    if r > 11.55:
        return BROWN
    # Orange loop with a gap on the upper right, like a wrapper twist.
    gap = -0.95 < ang < -0.15
    if r > 8.15:
        if gap and r > 9.3:
            return CREAM
        if r > 10.7:
            return ORANGE
        return BROWN if (x + y) % 7 == 0 else ORANGE
    if r > 7.35:
        return BROWN
    # Face.
    if abs(fx) <= 1.2 and 1.5 <= fy <= 3.4:
        return BROWN
    if 2.4 <= fy <= 4.6 and 1.6 <= abs(fx) <= 4.2:
        return BLUSH
    eye = (abs(abs(fx) - 3.15) <= 1.15) and abs(fy + 1.15) <= 1.25
    if eye:
        return INK
    pupil = (abs(abs(fx) - 3.5) <= 0.6) and abs(fy + 1.45) <= 0.6
    if pupil:
        return CREAM
    return CREAM_DARK if r > 6.4 else CREAM


def render(size, kind):
    n = 32
    im = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    px = im.load()
    cell = size / float(n)
    if kind == "bg":
        base = Image.new("RGBA", (size, size), CREAM)
        bpx = base.load()
        for y in range(size):
            for x in range(size):
                edge = min(x, y, size - 1 - x, size - 1 - y)
                if edge < size * 0.04:
                    bpx[x, y] = CREAM_DARK
        return base
    for cy in range(n):
        for cx in range(n):
            color = _cell_color(cx, cy, n)
            if color is None:
                continue
            if kind == "mono":
                color = (0, 0, 0, 255)
            x0 = int(round(cx * cell))
            y0 = int(round(cy * cell))
            x1 = int(round((cx + 1) * cell))
            y1 = int(round((cy + 1) * cell))
            for y in range(y0, max(y0 + 1, y1)):
                for x in range(x0, max(x0 + 1, x1)):
                    if 0 <= x < size and 0 <= y < size:
                        px[x, y] = color
    if kind == "full":
        bg = render(size, "bg")
        bg.alpha_composite(im)
        return bg
    return im


IOS_SIZES = [
    1024, 192, 180, 167, 152, 136, 128, 120, 114, 87, 80, 76, 60, 58, 40,
]
ANDROID_SIZES = [48, 72, 96, 144, 192, 512]


def main():
    ios = os.path.join(ROOT, "ios")
    android = os.path.join(ROOT, "android")
    os.makedirs(ios, exist_ok=True)
    os.makedirs(android, exist_ok=True)
    master = render(1024, "full")
    master.save(os.path.join(ROOT, "icon.png"))
    for size in IOS_SIZES:
        render(size, "full").save(os.path.join(ios, f"icon_{size}.png"))
        render(size, "mono").save(os.path.join(ios, f"icon_{size}_tinted.png"))
    for size in ANDROID_SIZES:
        render(size, "full").save(os.path.join(android, f"icon_{size}.png"))
    render(432, "fg").save(os.path.join(android, "adaptive_foreground_432.png"))
    render(432, "bg").save(os.path.join(android, "adaptive_background_432.png"))
    render(432, "mono").save(os.path.join(android, "adaptive_monochrome_432.png"))
    render(192, "full").save(os.path.join(android, "icon_192.png"))
    print("wrote icons under", ROOT)


if __name__ == "__main__":
    main()
