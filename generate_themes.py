#!/usr/bin/env python3

import chevron
import os
import shutil
import subprocess
import toml

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return '#{:02X}{:02X}{:02X}'.format(*rgb)

def lighten(hex_color, amount):
    rgb = hex_to_rgb(hex_color)
    return rgb_to_hex(tuple(min(int(c + (255 - c) * amount), 255) for c in rgb))

def darken(hex_color, amount):
    rgb = hex_to_rgb(hex_color)
    return rgb_to_hex(tuple(max(int(c * (1 - amount)), 0) for c in rgb))

def blend(hex1, hex2, ratio):
    rgb1 = hex_to_rgb(hex1)
    rgb2 = hex_to_rgb(hex2)
    return rgb_to_hex(tuple(int(rgb1[i] * (1 - ratio) + rgb2[i] * ratio) for i in range(3)))

def luminance(hex_color):
    r, g, b = hex_to_rgb(hex_color)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def relative_luminance(hex_color):
    r, g, b = hex_to_rgb(hex_color)
    def linear(channel):
        channel /= 255
        return channel / 12.92 if channel <= 0.04045 else ((channel + 0.055) / 1.055) ** 2.4
    return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)

def contrast_ratio(hex1, hex2):
    lighter = max(relative_luminance(hex1), relative_luminance(hex2))
    darker = min(relative_luminance(hex1), relative_luminance(hex2))
    return (lighter + 0.05) / (darker + 0.05)

def ensure_contrast(hex_color, background, min_ratio):
    color = hex_color
    for _ in range(12):
        if contrast_ratio(color, background) >= min_ratio:
            break
        color = darken(color, 0.12)
    return color

def is_dark_theme(background, foreground):
    return luminance(background) < luminance(foreground)

shutil.rmtree("scripts")
os.mkdir("scripts")

for dir in os.listdir("themes"):
    theme_name = dir.split(".")[0]

    with open(f"themes/{dir}", "r") as f:
        theme = toml.load(f)

    background = theme["background"]
    foreground = theme["foreground"]

    color01 = theme["color01"]
    color02 = theme["color02"]
    color03 = theme["color03"]
    color04 = theme["color04"]
    color05 = theme["color05"]
    color06 = theme["color06"]

    # Determine if theme is dark or light
    dark_theme = is_dark_theme(background, foreground)

    # Derived base-16 defaults: color00 acts as the panel surface and color08
    # as dimmed text, blended from the theme's own foreground/background so
    # they stay distinct on any palette. A given wash reads heavier on light
    # backgrounds, so dim takes a stronger wash there.
    color00 = theme.get("color00") or blend(background, foreground, 0.15)
    color08 = theme.get("color08") or blend(foreground, background, 0.40 if dark_theme else 0.25)

    # Light canvases keep the canonical neutral roles: grey (07) sits closer
    # to the background as a ghosted mid tone, and white (15) stays near-white
    # instead of inverting to near-black.
    if dark_theme:
        color07 = theme.get("color07") or lighten(foreground, 0.1)
        color15 = theme.get("color15") or lighten(foreground, 0.8)
    else:
        color07 = theme.get("color07") or blend(foreground, background, 0.50)
        color15 = theme.get("color15") or blend(foreground, background, 0.90)
    color208 = theme.get("color208") or blend(color01, color03, 0.5)

    # Light palettes pair a near-white background with accents that were
    # drawn for a dark canvas; darken any accent that cannot reach a
    # readable contrast floor so the palette comes together on light terms.
    if not dark_theme:
        for slot in ("color01", "color02", "color03", "color04", "color05", "color06"):
            locals()[slot] = ensure_contrast(locals()[slot], background, 3.0)

    # Bright colors: match normal if not present
    color09 = theme.get("color09") or color01
    color10 = theme.get("color10") or color02
    color11 = theme.get("color11") or color03
    color12 = theme.get("color12") or color04
    color13 = theme.get("color13") or color05
    color14 = theme.get("color14") or color06

    with open("template/default.mustache", "r") as file:
        f = file.read()
        args = {
            "template": f,
            "data": {
                "theme_name": theme_name,
                "foreground-hex": foreground[1:7],
                "foreground-hex-r": foreground[1:3],
                "foreground-hex-g": foreground[3:5],
                "foreground-hex-b": foreground[5:7],
                "background-hex": background[1:7],
                "background-hex-r": background[1:3],
                "background-hex-g": background[3:5],
                "background-hex-b": background[5:7],
                "base00-hex": color00[1:7],
                "base00-hex-r": color00[1:3],
                "base00-hex-g": color00[3:5],
                "base00-hex-b": color00[5:7],
                "base01-hex": color01[1:7],
                "base01-hex-r": color01[1:3],
                "base01-hex-g": color01[3:5],
                "base01-hex-b": color01[5:7],
                "base02-hex": color02[1:7],
                "base02-hex-r": color02[1:3],
                "base02-hex-g": color02[3:5],
                "base02-hex-b": color02[5:7],
                "base03-hex": color03[1:7],
                "base03-hex-r": color03[1:3],
                "base03-hex-g": color03[3:5],
                "base03-hex-b": color03[5:7],
                "base04-hex": color04[1:7],
                "base04-hex-r": color04[1:3],
                "base04-hex-g": color04[3:5],
                "base04-hex-b": color04[5:7],
                "base05-hex": color05[1:7],
                "base05-hex-r": color05[1:3],
                "base05-hex-g": color05[3:5],
                "base05-hex-b": color05[5:7],
                "base06-hex": color06[1:7],
                "base06-hex-r": color06[1:3],
                "base06-hex-g": color06[3:5],
                "base06-hex-b": color06[5:7],
                "base07-hex": color07[1:7],
                "base07-hex-r": color07[1:3],
                "base07-hex-g": color07[3:5],
                "base07-hex-b": color07[5:7],
                "base08-hex": color08[1:7],
                "base08-hex-r": color08[1:3],
                "base08-hex-g": color08[3:5],
                "base08-hex-b": color08[5:7],
                "base09-hex": color09[1:7],
                "base09-hex-r": color09[1:3],
                "base09-hex-g": color09[3:5],
                "base09-hex-b": color09[5:7],
                "base10-hex": color10[1:7],
                "base10-hex-r": color10[1:3],
                "base10-hex-g": color10[3:5],
                "base10-hex-b": color10[5:7],
                "base11-hex": color11[1:7],
                "base11-hex-r": color11[1:3],
                "base11-hex-g": color11[3:5],
                "base11-hex-b": color11[5:7],
                "base12-hex": color12[1:7],
                "base12-hex-r": color12[1:3],
                "base12-hex-g": color12[3:5],
                "base12-hex-b": color12[5:7],
                "base13-hex": color13[1:7],
                "base13-hex-r": color13[1:3],
                "base13-hex-g": color13[3:5],
                "base13-hex-b": color13[5:7],
                "base14-hex": color14[1:7],
                "base14-hex-r": color14[1:3],
                "base14-hex-g": color14[3:5],
                "base14-hex-b": color14[5:7],
                "base15-hex": color15[1:7],
                "base15-hex-r": color15[1:3],
                "base15-hex-g": color15[3:5],
                "base15-hex-b": color15[5:7],
                "base208-hex": color208[1:7],
                "base208-hex-r": color208[1:3],
                "base208-hex-g": color208[3:5],
                "base208-hex-b": color208[5:7],
                "mode": "dark" if dark_theme else "light",
                "colorfgbg": "15;0" if dark_theme else "0;15",
            },
        }
        render = chevron.render(**args)

    script_file = f"scripts/{theme_name}.sh"
    with open(script_file, "w") as f:
        for r in iter(render.splitlines()):
            f.write(f"{r}\n")

    subprocess.run(["chmod", "+x", script_file])
