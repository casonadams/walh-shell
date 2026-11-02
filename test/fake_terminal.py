#!/usr/bin/env python3
"""Run `walh palette --check` in a pty that plays the terminal: it answers OSC 4
color queries from the theme script itself. With `corrupt`, one answer is wrong
and with `mute` nothing answers.

Usage: fake_terminal.py REPO_DIR THEME [corrupt|mute]
"""
import os
import pty
import re
import select
import shutil
import sys
import tempfile
import time


def expected_colors(path):
    colors = {}
    text = open(path).read()
    for n, rgb in re.findall(r'^color(\d\d)="([0-9A-Fa-f/]+)"', text, re.M):
        colors[int(n)] = rgb.replace("/", "")
    m = re.search(r'^walh_palette256="([^"]+)"', text, re.M)
    for entry in m.group(1).split(","):
        idx, rgb = entry.split(";rgb:")
        if int(idx) != 208:
            colors[int(idx)] = rgb.replace("/", "")
    colors[208] = re.search(r'^color208="([^"]+)"', text, re.M).group(1).replace("/", "")
    return colors


def main():
    repo, theme = sys.argv[1], sys.argv[2]
    mode = sys.argv[3] if len(sys.argv) > 3 else ""
    colors = expected_colors(os.path.join(repo, "scripts", f"{theme}.sh"))
    home = tempfile.mkdtemp()
    master, slave = pty.openpty()
    pid = os.fork()
    if pid == 0:
        os.close(master)
        os.setsid()
        import fcntl
        import termios

        fcntl.ioctl(slave, termios.TIOCSCTTY, 0)
        for fd in (0, 1, 2):
            os.dup2(slave, fd)
        env = {k: v for k, v in os.environ.items() if not k.startswith("WALH_") and k != "TMUX"}
        env.update(HOME=home, TERM="xterm-256color", WALH_SHELL=repo)
        cmd = f'. "{repo}/walh.sh"; walh {theme} >/dev/null; walh palette --check; echo "EXIT=$?"'
        shell = os.environ.get("FAKE_SHELL", "bash")
        os.execve(shutil.which(shell), [shell, "-c", cmd], env)
    os.close(slave)

    out = b""
    buf = b""
    corrupted = False
    deadline = time.time() + 15
    while time.time() < deadline:
        if not select.select([master], [], [], 0.3)[0]:
            if b"EXIT=" in out:
                break
            continue
        try:
            chunk = os.read(master, 8192)
        except OSError:
            break
        if not chunk:
            break
        buf += chunk
        for m in list(re.finditer(rb"\x1b\]4;(\d+);\?\x1b\\", buf)):
            n = int(m.group(1))
            if mode == "mute":
                continue
            rgb = colors[n]
            if mode == "corrupt" and n == 100 and not corrupted:
                rgb = "000000"
                corrupted = True
            r, g, b = rgb[0:2], rgb[2:4], rgb[4:6]
            os.set_blocking(master, True)
            os.write(master, f"\x1b]4;{n};rgb:{r}{r}/{g}{g}/{b}{b}\x1b\\".encode())
        buf = re.sub(rb"\x1b\]4;\d+;\?\x1b\\", b"", buf)
        out += chunk
    os.close(master)
    try:
        os.kill(pid, 9)
    except ProcessLookupError:
        pass
    os.waitpid(pid, 0)
    shutil.rmtree(home, ignore_errors=True)
    text = re.sub(r"\x1b\][^\x1b]*\x1b\\", "", out.decode(errors="replace")).replace("\r", "")
    print(text)


if __name__ == "__main__":
    main()
