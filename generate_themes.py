#!/usr/bin/env python3
import math
import os
import shutil

import chevron
import toml


def srgb_to_linear(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

def linear_to_srgb(c):
    c = max(0.0, min(1.0, c))
    return 12.92 * c if c <= 0.0031308 else 1.055 * (c ** (1.0 / 2.4)) - 0.055

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def rgb_to_hex(rgb):
    return '#{:02X}{:02X}{:02X}'.format(*[max(0, min(255, round(c))) for c in rgb])

def rgb_to_oklab(rgb):
    r, g, b = [srgb_to_linear(c) for c in rgb]
    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b
    l_ = l ** (1.0 / 3.0) if l > 0 else 0
    m_ = m ** (1.0 / 3.0) if m > 0 else 0
    s_ = s ** (1.0 / 3.0) if s > 0 else 0
    L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
    a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
    b_ = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_
    return L, a, b_

def oklab_to_linear(L, a, b_):
    l_ = L + 0.3963377774 * a + 0.2158037573 * b_
    m_ = L - 0.1055613458 * a - 0.0638541728 * b_
    s_ = L - 0.0894841775 * a - 1.2914855480 * b_
    l = l_ ** 3
    m = m_ ** 3
    s = s_ ** 3
    r = +4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s
    g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s
    b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s
    return r, g, b

def is_in_gamut(L, a, b_):
    r, g, b = oklab_to_linear(L, a, b_)
    eps = 1e-4
    return -eps <= r <= 1.0 + eps and -eps <= g <= 1.0 + eps and -eps <= b <= 1.0 + eps

def oklab_to_rgb_gamut_mapped(L, a, b_):
    if is_in_gamut(L, a, b_):
        r, g, b = oklab_to_linear(L, a, b_)
        return (linear_to_srgb(r) * 255, linear_to_srgb(g) * 255, linear_to_srgb(b) * 255)
    C = math.sqrt(a * a + b_ * b_)
    if C < 1e-6:
        r, g, b = oklab_to_linear(L, 0, 0)
        return (linear_to_srgb(r) * 255, linear_to_srgb(g) * 255, linear_to_srgb(b) * 255)
    unit_a = a / C
    unit_b = b_ / C
    lo, hi = 0.0, C
    for _ in range(16):
        mid = (lo + hi) / 2.0
        if is_in_gamut(L, mid * unit_a, mid * unit_b):
            lo = mid
        else:
            hi = mid
    r, g, b = oklab_to_linear(L, lo * unit_a, lo * unit_b)
    return (linear_to_srgb(r) * 255, linear_to_srgb(g) * 255, linear_to_srgb(b) * 255)

def oklch_brighten(hex_color, dark=True):
    rgb = hex_to_rgb(hex_color)
    L, a, b_ = rgb_to_oklab(rgb)
    C = math.sqrt(a * a + b_ * b_)
    h = math.atan2(b_, a)
    if dark:
        new_L = min(0.92, L + 0.12)
        new_C = C * 1.05
    else:
        new_L = max(0.25, L - 0.08)
        new_C = C * 1.15
    new_a = new_C * math.cos(h)
    new_b = new_C * math.sin(h)
    return rgb_to_hex(oklab_to_rgb_gamut_mapped(new_L, new_a, new_b))

def derive_neutrals(bg_hex, fg_hex, dark=True):
    bg_L, bg_a, bg_b = rgb_to_oklab(hex_to_rgb(bg_hex))
    fg_L, fg_a, fg_b = rgb_to_oklab(hex_to_rgb(fg_hex))
    if dark:
        c00_L = max(0.0, bg_L - 0.04)
        c08_L = bg_L + (fg_L - bg_L) * 0.38
        c15_L = min(0.99, fg_L + 0.08)
    else:
        c00_L = max(0.0, bg_L - 0.045)
        c08_L = bg_L - (bg_L - fg_L) * 0.38
        c15_L = max(0.01, fg_L - 0.10)
    c00 = rgb_to_hex(oklab_to_rgb_gamut_mapped(c00_L, bg_a, bg_b))
    c08 = rgb_to_hex(oklab_to_rgb_gamut_mapped(c08_L, (bg_a + fg_a) / 2, (bg_b + fg_b) / 2))
    c15 = rgb_to_hex(oklab_to_rgb_gamut_mapped(c15_L, fg_a, fg_b))
    return c00, fg_hex, c08, c15

def derive_orange(c01_hex, c03_hex):
    L1, a1, b1 = rgb_to_oklab(hex_to_rgb(c01_hex))
    L3, a3, b3 = rgb_to_oklab(hex_to_rgb(c03_hex))
    L = (L1 + L3) / 2
    a = (a1 + a3) / 2
    b = (b1 + b3) / 2
    return rgb_to_hex(oklab_to_rgb_gamut_mapped(L, a, b))

def darken(hex_color, amount):
    rgb = hex_to_rgb(hex_color)
    return rgb_to_hex(tuple(max(int(c * (1 - amount)), 0) for c in rgb))

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
    for _ in range(20):
        if contrast_ratio(color, background) >= min_ratio:
            break
        color = darken(color, 0.08)
    return color

def is_dark_theme(background, foreground):
    return relative_luminance(background) < relative_luminance(foreground)


def gen_theme():
    output_dir = "scripts"
    if os.path.exists(output_dir):
        shutil.rmtree(output_dir)
    os.makedirs(output_dir, exist_ok=True)

    with open("template/default.mustache", "r") as f:
        template = f.read()

    theme_entries = []
    for theme_file in sorted(os.listdir("themes")):
        if not theme_file.endswith(".toml"):
            continue

        theme_path = os.path.join("themes", theme_file)
        with open(theme_path, "r") as f:
            data = toml.load(f)

        if "dark" in data or "light" in data:
            family_name = data.get("name", os.path.splitext(theme_file)[0])
            d_slug = data.get("dark", {}).get("slug", f"{family_name}-dark") if "dark" in data else None
            l_slug = data.get("light", {}).get("slug", f"{family_name}-light") if "light" in data else None
            if "dark" in data:
                theme_entries.append((d_slug, dict(data["dark"]), l_slug))
            if "light" in data:
                theme_entries.append((l_slug, dict(data["light"]), d_slug))
        elif data.get("foreground") and data.get("background"):
            slug = os.path.splitext(theme_file)[0]
            theme_entries.append((slug, data, None))

    manifest_lines = []
    for theme_name, theme, pair_slug in theme_entries:
        foreground = theme.get("foreground")
        background = theme.get("background")
        if not foreground or not background:
            continue
        dark_theme = is_dark_theme(background, foreground)

        color01 = theme.get("color01") or "#CC6666"
        color02 = theme.get("color02") or "#B5BD68"
        color03 = theme.get("color03") or "#F0C674"
        color04 = theme.get("color04") or "#81A2BE"
        color05 = theme.get("color05") or "#B294BB"
        color06 = theme.get("color06") or "#8ABE87"

        d_c00, d_c07, d_c08, d_c15 = derive_neutrals(background, foreground, dark_theme)

        color00 = theme.get("color00") or d_c00
        color07 = theme.get("color07") or d_c07
        color08 = theme.get("color08") or d_c08
        color15 = theme.get("color15") or d_c15

        color09 = theme.get("color09") or oklch_brighten(color01, dark_theme)
        color10 = theme.get("color10") or oklch_brighten(color02, dark_theme)
        color11 = theme.get("color11") or oklch_brighten(color03, dark_theme)
        color12 = theme.get("color12") or oklch_brighten(color04, dark_theme)
        color13 = theme.get("color13") or oklch_brighten(color05, dark_theme)
        color14 = theme.get("color14") or oklch_brighten(color06, dark_theme)

        color208 = theme.get("color208") or derive_orange(color01, color03)

        if not dark_theme:
            foreground = ensure_contrast(foreground, background, 4.5)
            for slot in (
                "color01",
                "color02",
                "color03",
                "color04",
                "color05",
                "color06",
                "color09",
                "color10",
                "color11",
                "color12",
                "color13",
                "color14",
                "color208",
            ):
                locals()[slot] = ensure_contrast(locals()[slot], background, 3.0)

        colorfgbg = "15;0" if dark_theme else "0;15"
        mode = "dark" if dark_theme else "light"

        color_map = {
            "foreground": foreground,
            "background": background,
            "base208": color208,
        }
        for i in range(16):
            color_map[f"base{i:02d}"] = locals()[f"color{i:02d}"]

        context = {
            "theme_name": theme_name,
            "theme": theme_name,
            "mode": mode,
            "colorfgbg": colorfgbg,
        }
        for prefix, hex_val in color_map.items():
            h = hex_val.lstrip("#")
            context[f"{prefix}-hex"] = h
            context[f"{prefix}-hex-r"] = h[0:2]
            context[f"{prefix}-hex-g"] = h[2:4]
            context[f"{prefix}-hex-b"] = h[4:6]

        rendered = chevron.render(template, context)

        output_path = os.path.join(output_dir, f"{theme_name}.sh")
        with open(output_path, "w") as f:
            f.write(rendered)
        os.chmod(output_path, 0o755)
        manifest_lines.append(f"{theme_name}\t{mode}\t{pair_slug or ''}\n")

    manifest_lines.sort()
    manifest_path = os.path.join(output_dir, ".manifest")
    with open(manifest_path, "w") as f:
        f.writelines(manifest_lines)


if __name__ == "__main__":
    gen_theme()
