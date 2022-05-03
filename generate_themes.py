#!/usr/bin/env python

import chevron
import os
import shutil
import subprocess
import toml

shutil.rmtree("scripts")
os.mkdir("scripts")

for dir in os.listdir("themes"):
    theme_name = dir.split(".")[0]

    with open(f"themes/{dir}", "r") as f:
        theme = toml.load(f)

    background = theme["background"]
    foreground = theme["foreground"]

    color00 = theme["color00"]
    color01 = theme["color01"]
    color02 = theme["color02"]
    color03 = theme["color03"]
    color04 = theme["color04"]
    color05 = theme["color05"]
    color06 = theme["color06"]
    color07 = theme["color07"]
    color08 = theme["color08"]
    color09 = theme["color09"]
    color10 = theme["color10"]
    color11 = theme["color11"]
    color12 = theme["color12"]
    color13 = theme["color13"]
    color14 = theme["color14"]
    color15 = theme["color15"]

    color208 = theme["color208"]
    color247 = theme["color247"]

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
                "base247-hex": color247[1:7],
                "base247-hex-r": color247[1:3],
                "base247-hex-g": color247[3:5],
                "base247-hex-b": color247[5:7],
            },
        }
        render = chevron.render(**args)

    script_file = f"scripts/{theme_name}.sh"
    with open(script_file, "w") as f:
        for r in iter(render.splitlines()):
            f.write(f"{r}\n")

    subprocess.run(["chmod", "+x", script_file])
