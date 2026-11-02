import json
import os
import re
import unittest

REPO_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class TestWebArtifacts(unittest.TestCase):
    def test_themes_data_js_validity(self):
        data_path = os.path.join(REPO_DIR, "www", "js", "themes-data.js")
        self.assertTrue(os.path.isfile(data_path), f"Missing {data_path}")

        with open(data_path, "r", encoding="utf-8") as f:
            content = f.read()

        match = re.search(r"window\.WALH_THEMES\s*=\s*(\[[\s\S]*\]);", content)
        self.assertIsNotNone(match, "Could not find window.WALH_THEMES in themes-data.js")

        themes = json.loads(match.group(1))
        self.assertGreaterEqual(len(themes), 40, "Expected at least 40 themes")

        hex_pattern = re.compile(r"^#[0-9a-fA-F]{6}$")

        for item in themes:
            self.assertIn("slug", item)
            self.assertIn("family", item)
            self.assertIn("mode", item)
            self.assertIn(item["mode"], ("dark", "light"))
            self.assertTrue(hex_pattern.match(item["background"]), f"Invalid background in {item['slug']}")
            self.assertTrue(hex_pattern.match(item["foreground"]), f"Invalid foreground in {item['slug']}")
            self.assertTrue(hex_pattern.match(item["color208"]), f"Invalid color208 in {item['slug']}")
            self.assertEqual(len(item["colors"]), 16, f"Theme {item['slug']} does not have 16 colors")
            for i, c in enumerate(item["colors"]):
                self.assertTrue(hex_pattern.match(c), f"Invalid color{i:02d} in {item['slug']}: {c}")

    def test_parity_with_manifest(self):
        manifest_path = os.path.join(REPO_DIR, "scripts", ".manifest")
        self.assertTrue(os.path.isfile(manifest_path), f"Missing {manifest_path}")

        manifest_slugs = set()
        with open(manifest_path, "r", encoding="utf-8") as f:
            for line in f:
                parts = line.strip().split("\t")
                if parts and parts[0]:
                    manifest_slugs.add(parts[0])

        data_path = os.path.join(REPO_DIR, "www", "js", "themes-data.js")
        with open(data_path, "r", encoding="utf-8") as f:
            content = f.read()
        match = re.search(r"window\.WALH_THEMES\s*=\s*(\[[\s\S]*\]);", content)
        web_themes = json.loads(match.group(1))
        web_slugs = {t["slug"] for t in web_themes}

        self.assertEqual(
            manifest_slugs,
            web_slugs,
            f"Difference between manifest and web themes: {manifest_slugs ^ web_slugs}",
        )

    def test_light_themes_meet_contrast_floor(self):
        def luminance(hex_color):
            def linear(c):
                c /= 255
                return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4

            h = hex_color.lstrip("#")
            r, g, b = (int(h[i : i + 2], 16) for i in (0, 2, 4))
            return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)

        def contrast(a, b):
            la, lb = luminance(a), luminance(b)
            return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)

        data_path = os.path.join(REPO_DIR, "www", "js", "themes-data.js")
        with open(data_path, "r", encoding="utf-8") as f:
            content = f.read()
        themes = json.loads(re.search(r"window\.WALH_THEMES\s*=\s*(\[[\s\S]*\]);", content).group(1))

        accent_slots = [1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14]
        for item in (t for t in themes if t["mode"] == "light"):
            bg = item["background"]
            self.assertGreaterEqual(contrast(item["foreground"], bg), 4.5, f"{item['slug']} foreground")
            for slot in accent_slots:
                self.assertGreaterEqual(contrast(item["colors"][slot], bg), 3.0, f"{item['slug']} color{slot:02d}")
            self.assertGreaterEqual(contrast(item["color208"], bg), 3.0, f"{item['slug']} color208")

    def test_terminal_exports_exist_and_parse(self):
        manifest_path = os.path.join(REPO_DIR, "scripts", ".manifest")
        with open(manifest_path, "r", encoding="utf-8") as f:
            slugs = [line.split("\t")[0] for line in f if line.strip()]

        try:
            import tomllib
        except ImportError:  # Python < 3.11
            tomllib = None

        for slug in slugs:
            for rel in (f"kitty/{slug}.conf", f"alacritty/{slug}.toml", f"ghostty/{slug}", f"wezterm/{slug}.toml"):
                path = os.path.join(REPO_DIR, "exports", rel)
                self.assertTrue(os.path.isfile(path), f"Missing export {rel}")
            if tomllib:
                with open(os.path.join(REPO_DIR, "exports", f"alacritty/{slug}.toml"), "rb") as f:
                    self.assertEqual(len(tomllib.load(f)["colors"]["indexed"]), 240, slug)
                with open(os.path.join(REPO_DIR, "exports", f"wezterm/{slug}.toml"), "rb") as f:
                    self.assertEqual(len(tomllib.load(f)["colors"]["indexed"]), 240, slug)
            with open(os.path.join(REPO_DIR, "exports", f"kitty/{slug}.conf"), "r", encoding="utf-8") as f:
                self.assertEqual(sum(1 for line in f if line.startswith("color")), 256, slug)

    def test_web_static_assets(self):
        assets = [
            ("www", "index.html"),
            ("www", "css", "style.css"),
            ("www", "js", "app.js"),
            ("www", "favicon.svg"),
            ("www", ".nojekyll"),
        ]
        for asset in assets:
            path = os.path.join(REPO_DIR, *asset)
            self.assertTrue(os.path.isfile(path), f"Expected static asset {path} to exist")

        index_path = os.path.join(REPO_DIR, "www", "index.html")
        with open(index_path, "r", encoding="utf-8") as f:
            index_html = f.read()

        self.assertIn("zload", index_html)
        self.assertIn("https://github.com/casonadams/zload", index_html)
        self.assertIn("js/themes-data.js", index_html)
        self.assertIn("js/app.js", index_html)
        self.assertIn("css/style.css", index_html)


if __name__ == "__main__":
    unittest.main()
