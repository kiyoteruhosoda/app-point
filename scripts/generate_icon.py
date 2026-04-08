#!/usr/bin/env python3
"""Generate app icon PNGs for PointBook.

Run from the project root:
    python3 scripts/generate_icon.py

Outputs:
    assets/icon/app_icon.png          — master 1024x1024
    android/app/src/main/res/mipmap-mdpi/ic_launcher.png      — 48x48
    android/app/src/main/res/mipmap-hdpi/ic_launcher.png      — 72x72
    android/app/src/main/res/mipmap-xhdpi/ic_launcher.png     — 96x96
    android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png    — 144x144
    android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png   — 192x192
"""

import os
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
CENTER = SIZE // 2  # 512

MASTER_PATH = os.path.join("assets", "icon", "app_icon.png")

MIPMAP_SIZES = {
    "mipmap-mdpi":    48,
    "mipmap-hdpi":    72,
    "mipmap-xhdpi":   96,
    "mipmap-xxhdpi":  144,
    "mipmap-xxxhdpi": 192,
}
ANDROID_RES = os.path.join("android", "app", "src", "main", "res")


def generate_master() -> Image.Image:
    # --- 1. Gradient background ---
    bg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    from_color = (0xBF, 0x36, 0x0C)   # deep amber #BF360C
    to_color   = (0xFF, 0xD7, 0x40)   # golden yellow #FFD740

    pixels = bg.load()
    for y in range(SIZE):
        for x in range(SIZE):
            t = (x + y) / (2.0 * (SIZE - 1))
            r = int(from_color[0] + t * (to_color[0] - from_color[0]))
            g = int(from_color[1] + t * (to_color[1] - from_color[1]))
            b = int(from_color[2] + t * (to_color[2] - from_color[2]))
            pixels[x, y] = (r, g, b, 255)

    # --- 2. Rounded-square mask (corner_radius=230) ---
    mask = Image.new("L", (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=230, fill=255)
    bg.putalpha(mask)

    # --- 3. Star vertices ---
    # 4-pointed elongated sparkle star (✦ style)
    # vertical outer=380, horizontal outer=200, inner waist=55 (at 45°: ≈39px)
    star_verts = [
        (512, 132),   # top tip
        (551, 473),   # upper-right waist
        (712, 512),   # right tip
        (551, 551),   # lower-right waist
        (512, 892),   # bottom tip
        (473, 551),   # lower-left waist
        (312, 512),   # left tip
        (473, 473),   # upper-left waist
    ]

    # --- 4. Drop shadow ---
    shadow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ImageDraw.Draw(shadow_layer).polygon(star_verts, fill=(0, 0, 0, 153))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=20))
    shadow_shifted = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shadow_shifted.paste(shadow_layer, (0, 8))

    # --- 5. Star (white) ---
    star_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    ImageDraw.Draw(star_layer).polygon(star_verts, fill=(255, 255, 255, 245))

    # --- 6. Center glow ---
    glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_r = 45
    ImageDraw.Draw(glow_layer).ellipse(
        [CENTER - glow_r, CENTER - glow_r, CENTER + glow_r, CENTER + glow_r],
        fill=(255, 255, 255, 255),
    )
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=14))

    # --- 7. Composite ---
    result = bg.copy()
    result = Image.alpha_composite(result, shadow_shifted)
    result = Image.alpha_composite(result, star_layer)
    result = Image.alpha_composite(result, glow_layer)

    return result


def main() -> None:
    print("Generating master icon...")
    master = generate_master()

    os.makedirs(os.path.dirname(MASTER_PATH), exist_ok=True)
    master.save(MASTER_PATH, "PNG")
    print(f"  Saved {MASTER_PATH}")

    # Convert to RGB for mipmap PNGs (no transparency needed for launcher icons)
    master_rgb = master.convert("RGB")

    print("Generating Android mipmap icons...")
    for density, px in MIPMAP_SIZES.items():
        out_dir = os.path.join(ANDROID_RES, density)
        out_path = os.path.join(out_dir, "ic_launcher.png")
        resized = master_rgb.resize((px, px), Image.LANCZOS)
        resized.save(out_path, "PNG")
        print(f"  Saved {out_path}  ({px}x{px})")

    print("Done.")


if __name__ == "__main__":
    main()
