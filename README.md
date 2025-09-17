# walh-shell

zsh walh-shell plugin

## example install with zinit

```zsh
zinit wait lucid for \
  OMZL::key-bindings.zsh \
  OMZL::history.zsh \
  OMZP::git \
  casonadams/walh-shell \
  ;
```

## change terminal colors

```sh
# onedark theme
walh_onedark
```

```sh
# onelight theme
walh_onelight
```

## tmux Truecolor and Dynamic Color Troubleshooting

If you want to change terminal colors dynamically (e.g., using walh-shell scripts) **inside tmux**, you need to ensure tmux is configured to allow passthrough of escape sequences and truecolor support.

**For tmux 3.3 and newer, add this to your `~/.tmux.conf`:**
```tmux
set -g allow-passthrough on
set-option -g default-terminal "xterm-256color"
set-option -sa terminal-overrides ",${TERM}:RGB"
```

**For older tmux versions:**
```tmux
set-option -g default-terminal "xterm-256color"
set-option -sa terminal-overrides ",${TERM}:RGB"
```

After updating your config, restart tmux completely:
```sh
tmux kill-server
tmux
```

