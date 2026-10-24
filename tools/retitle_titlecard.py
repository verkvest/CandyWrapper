#!/usr/bin/env python3
"""Replace the baked-in original title on frame 0 of Title.png.

Keeps Harmony Honey Monroe's pixel art (character, banner, author line).
Only the old wordmark is covered and redrawn as Liltkin.
"""
import os

from PIL import Image

PATH = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "media", "image", "Title.png"))
CREAM = (255, 251, 204, 255)
BROWN = (116, 49, 1, 255)
ORANGE = (254, 157, 22, 255)
INK = (0, 0, 0, 255)

# 5-wide glyphs, 7 rows. I is narrower.
FONT = {
    "L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
    "I": ["111", "010", "010", "010", "010", "010", "111"],
    "T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
    "K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
    "N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
}


def text_width(text, scale, gap):
    w = 0
    for i, ch in enumerate(text):
        w += len(FONT[ch][0]) * scale
        if i != len(text) - 1:
            w += gap
    return w


def draw_text(px, text, ox, oy, scale):
    gap = scale
    cursor = ox
    for ch in text:
        glyph = FONT[ch]
        gw = len(glyph[0])
        gh = len(glyph)
        for gy, row in enumerate(glyph):
            for gx, bit in enumerate(row):
                if bit != "1":
                    continue
                for sy in range(scale):
                    for sx in range(scale):
                        x = cursor + gx * scale + sx
                        y = oy + gy * scale + sy
                        # 1px ink outline, orange cap, brown body.
                        for oy2 in (-1, 0, 1):
                            for ox2 in (-1, 0, 1):
                                px[x + ox2, y + oy2] = INK
        cursor += gw * scale + gap
    cursor = ox
    for ch in text:
        glyph = FONT[ch]
        gw = len(glyph[0])
        for gy, row in enumerate(glyph):
            for gx, bit in enumerate(row):
                if bit != "1":
                    continue
                col = ORANGE if gy <= 1 else BROWN
                for sy in range(scale):
                    for sx in range(scale):
                        x = cursor + gx * scale + sx
                        y = oy + gy * scale + sy
                        px[x, y] = col
        cursor += gw * scale + gap


def main():
    im = Image.open(PATH).convert("RGBA")
    px = im.load()
    # Frame 0 wordmark band, inside the card border. Author credit lower down stays.
    for y in range(18, 52):
        for x in range(16, 128):
            px[x, y] = CREAM
    scale = 2
    gap = scale
    # Two short lines read as the name; the band is only ~34px tall.
    lines = ["LILT", "KIN"]
    line_h = 7 * scale
    leading = 2
    block_h = line_h * len(lines) + leading * (len(lines) - 1)
    top = 18 + max(0, (34 - block_h) // 2)
    for i, line in enumerate(lines):
        tw = text_width(line, scale, gap)
        ox = 16 + (112 - tw) // 2
        oy = top + i * (line_h + leading)
        draw_text(px, line, ox, oy, scale)
    im.save(PATH)
    print("updated", PATH)


if __name__ == "__main__":
    main()
