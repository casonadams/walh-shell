#!/usr/bin/env python3
"""Drive an interactive zsh in a pty and report the background colors (OSC 11)
emitted while a theme name is completed, cleared, and accepted.

Usage: zsh_tab_preview.py REPO_DIR [preview=false]
Prints KEY=value lines for the shell test to assert on.
"""
import os
import pty
import re
import select
import shutil
import sys
import tempfile


def main():
    repo_dir = sys.argv[1]
    preview = "false" if "preview=false" in sys.argv[2:] else "true"
    home = tempfile.mkdtemp()
    with open(os.path.join(home, ".zshrc"), "w") as f:
        f.write(
            "autoload -Uz compinit && compinit -D -u\n"
            f"export WALH_SHELL='{repo_dir}'\n"
            f"export WALH_SHELL_PREVIEW={preview}\n"
            "unset TMUX\n"
            f". '{repo_dir}/walh-shell.plugin.zsh'\n"
        )

    master, slave = pty.openpty()
    pid = os.fork()
    if pid == 0:
        os.close(master)
        os.setsid()
        for fd in (0, 1, 2):
            os.dup2(slave, fd)
        env = {k: v for k, v in os.environ.items() if not k.startswith("WALH_")}
        env.update(ZDOTDIR=home, HOME=home, TERM="xterm-256color")
        zsh = shutil.which("zsh") or "/bin/zsh"
        os.execve(zsh, [zsh, "-i"], env)

    os.close(slave)

    def drain(timeout=0.4):
        data = b""
        while select.select([master], [], [], timeout)[0]:
            chunk = os.read(master, 8192)
            if not chunk:
                break
            data += chunk
        return data

    def backgrounds(data):
        return [m.decode().lower() for m in re.findall(rb"\]11;rgb:([0-9A-Fa-f/]+)", data)]

    drain(1.5)
    os.write(master, b"walh nord\n")
    drain()

    os.write(master, b"walh gruvbox-dar\t")
    print("TAB=" + ",".join(backgrounds(drain())))

    os.write(master, b"\x15")
    print("CLEARED=" + ",".join(backgrounds(drain())))

    os.write(master, b"walh dracula\n")
    drain()
    os.write(master, b"echo THEME=$WALH_THEME\n")
    out = drain().decode(errors="replace")
    print("FINAL=" + ",".join(re.findall(r"\nTHEME=(\S+)", out.replace("\r", ""))))

    saved = os.path.join(home, ".local", "state", "walh", "current_theme")
    print("SAVED=" + os.path.basename(os.readlink(saved)))

    os.close(master)
    os.waitpid(pid, 0)
    shutil.rmtree(home, ignore_errors=True)


if __name__ == "__main__":
    main()
