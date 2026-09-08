#!/usr/bin/env python3
"""Generate AppShelf PNG/ICO launcher assets from the brand palette."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

# Slate + sage palette (matches appshelf.scss / AsColors)
BG_TOP = (58, 122, 114)      # #3A7A72
BG_BOTTOM = (35, 79, 74)     # #234F4A
FRAME = (232, 242, 240)      # #E8F2F0
TILE_A = (232, 242, 240)
TILE_B = (122, 166, 158)     # #7AA69E
TILE_C = (91, 143, 135)      # #5B8F87
TILE_D = (197, 221, 216)     # #C5DDD8


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def gradient_bg(size: int) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    px = img.load()
    for y in range(size):
        t = y / max(size - 1, 1)
        r = lerp(BG_TOP[0], BG_BOTTOM[0], t)
        g = lerp(BG_TOP[1], BG_BOTTOM[1], t)
        b = lerp(BG_TOP[2], BG_BOTTOM[2], t)
        for x in range(size):
            px[x, y] = (r, g, b, 255)
    return img


def rounded_rect(
    draw: ImageDraw.ImageDraw,
    box: tuple[float, float, float, float],
    radius: float,
    fill=None,
    outline=None,
    width: int = 1,
) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def draw_icon(size: int) -> Image.Image:
    img = gradient_bg(size)
    draw = ImageDraw.Draw(img)

    pad = size * 0.125
    corner = size * 0.22
    rounded_rect(draw, (0, 0, size - 1, size - 1), corner, fill=None)

    # Shelf frame
    fx0, fy0 = pad * 1.05, pad * 1.1
    fx1, fy1 = size - pad * 1.05, size - pad * 0.95
    frame_r = size * 0.14
    stroke = max(2, int(size * 0.034))
    rounded_rect(
        draw,
        (fx0, fy0, fx1, fy1),
        frame_r,
        fill=None,
        outline=FRAME + (235,),
        width=stroke,
    )

    inner_w = fx1 - fx0
    inner_h = fy1 - fy0
    tile = inner_w * 0.38
    gap = inner_w * 0.06
    tx = fx0 + gap * 1.4
    ty = fy0 + gap * 1.3
    tr = size * 0.062

    rounded_rect(draw, (tx, ty, tx + tile, ty + tile), tr, fill=TILE_A + (255,))
    rounded_rect(
        draw,
        (tx + tile + gap, ty, tx + tile + gap + tile, ty + tile),
        tr,
        fill=TILE_B + (255,),
    )

    shelf_y = fy0 + inner_h * 0.58
    draw.line(
        [(fx0 + gap * 1.4, shelf_y), (fx1 - gap * 1.4, shelf_y)],
        fill=FRAME + (220,),
        width=max(2, int(size * 0.028)),
    )

    small = inner_w * 0.24
    sy = shelf_y + gap * 1.1
    sx = fx0 + gap * 1.4
    sr = size * 0.04
    rounded_rect(draw, (sx, sy, sx + small, sy + small), sr, fill=TILE_C + (255,))
    rounded_rect(
        draw,
        (sx + small + gap * 0.9, sy, sx + small + gap * 0.9 + small, sy + small),
        sr,
        fill=TILE_B + (255,),
    )
    rounded_rect(
        draw,
        (sx + (small + gap * 0.9) * 2, sy, sx + (small + gap * 0.9) * 2 + small * 0.85, sy + small),
        sr,
        fill=TILE_D + (255,),
    )

    # Clip to rounded square
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, size, size), corner, fill=255)
    img.putalpha(mask)
    return img


def save_png(path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    draw_icon(size).save(path, format="PNG", optimize=True)


def save_ico(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    sizes = [16, 32, 48, 64, 128, 256]
    images = [draw_icon(s) for s in sizes]
    images[0].save(
        path,
        format="ICO",
        sizes=[(s, s) for s in sizes],
        append_images=images[1:],
    )


def main() -> None:
    root = Path(__file__).resolve().parents[1]
    web_root = root.parent / "appshelf"

    save_png(root / "assets/brand/app_icon.png", 1024)
    save_png(root / "assets/brand/appshelf-mark.png", 512)

    if web_root.exists():
        save_ico(web_root / "public/favicon.ico")
        save_png(web_root / "public/apple-touch-icon.png", 180)

    print("Generated launcher assets.")


if __name__ == "__main__":
    main()
