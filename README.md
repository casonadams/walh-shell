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

## using with vim

install [walh](https://github.com/casonadams/walh) colorscheme

```vimrc
set notermguicolors
colorscheme walh-default
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

### Vim: Seeing Escape Sequences Instead of Colors?

- Make sure your `$TERM` is set to `xterm-256color` (outside tmux) and `xterm-256color` or `tmux-256color` (inside tmux).
- Try toggling `:set termguicolors` and `:set notermguicolors` in Vim to see which works best for your terminal and theme.
- If you still see escape codes, check your terminal emulator and tmux config as above.
