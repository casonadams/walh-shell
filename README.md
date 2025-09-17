# walh-shell

**A fast, modern, and extensible Zsh (and Bash) plugin for instant terminal color theme switching.**

walh-shell lets you instantly change your terminal’s color scheme with a single command. Choose from dozens of beautiful, curated themes, or create your own using simple TOML files. Themes are applied live—no need to restart your shell!

---

## Features

- **Instant theme switching**: Change your terminal colors on the fly with a single command or alias.
- **Curated & custom themes**: Includes a wide selection of popular color schemes (One Dark, Dracula, Solarized, GitHub, and more).
- **Easy customization**: Define your own themes in TOML, or tweak existing ones.
- **Fast & lightweight**: No Python or Node.js required at runtime—just shell scripts.
- **Zsh & Bash support**: Works in both Zsh and Bash shells.
- **Plugin-friendly**: Simple to install with any Zsh plugin manager (zinit, zplug, etc).
- **Truecolor & tmux support**: Works with modern terminals and tmux (see below for config tips).

---

## Installation

### With [zinit](https://github.com/zdharma-continuum/zinit)

```zsh
zinit wait lucid for \
  OMZL::key-bindings.zsh \
  OMZL::history.zsh \
  OMZP::git \
  casonadams/walh-shell
```

### With Oh My Zsh

You can use **walh-shell** as a custom plugin in [Oh My Zsh](https://ohmyz.sh/):

1. **Clone the repository into your custom plugins folder:**
   ```sh
   git clone https://github.com/casonadams/walh-shell.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/walh-shell
   ```
2. **Add `walh-shell` to your plugin list**
   Edit your `~/.zshrc` and add `walh-shell` to the `plugins=(...)` array:
   ```sh
   plugins=(... walh-shell)
   ```
3. **Reload your shell**
   ```sh
   source ~/.zshrc
   ```

Now you can use the `walh` command to switch themes!

### Manual (Zsh)

Clone this repo and source the plugin in your `.zshrc`:

```sh
git clone https://github.com/casonadams/walh-shell.git ~/.walh-shell
echo 'source ~/.walh-shell/walh-shell.plugin.zsh' >> ~/.zshrc
```

---

## Bash Usage

You can use walh-shell in Bash as well!

1. **Clone the repo:**
   ```sh
   git clone https://github.com/casonadams/walh-shell.git ~/.walh-shell
   ```
2. **Source the helper in your `.bashrc`:**
   ```sh
   source ~/.walh-shell/profile_helper.sh
   ```
3. **Reload your shell or run:**
   ```sh
   source ~/.bashrc
   ```
4. **Switch themes with the same aliases:**
   ```sh
   walh_onedark
   walh_dracula
   # ...and so on!
   ```

> **Note:** All theme aliases (`walh_<theme>`) work in Bash just like in Zsh.

---

## Usage

After installation, use the `walh_<theme>` alias to instantly switch themes:

```sh
walh_onedark
walh_dracula
walh_solarized-dark
```

To see all available themes, use the built-in helper:

```sh
walh_list_themes
```

---

## Creating & Customizing Themes

- Themes are defined in simple TOML files in the `themes/` directory.
- To add your own, copy an existing `.toml` file, edit the colors, and re-run `generate_themes.py` to generate the shell script.
- PRs for new themes are welcome!

---

## tmux Truecolor & Dynamic Color Troubleshooting

If you want to change terminal colors dynamically **inside tmux**, ensure tmux is configured for passthrough and truecolor:

**For tmux 3.3 and newer:**
```tmux
set -g allow-passthrough on
set-option -g default-terminal "xterm-256color"
set-option -sa terminal-overrides ",${TERM}:RGB"
```

**For older tmux:**
```tmux
set-option -g default-terminal "xterm-256color"
set-option -sa terminal-overrides ",${TERM}:RGB"
```

---

## Contributing

- Found a bug? Want to add a new theme? PRs and issues are welcome!
- Please keep new themes consistent with the TOML format and color slot order.

---

## License

MIT

---

**Enjoy beautiful, instant terminal themes with walh-shell!**
