# dotfiles

A modern, **secret-free** dotfiles baseline for [Coder](https://coder.com)
workspaces (and any Linux box). Applied automatically on workspace start, or
installed by hand, so you get a complete modern shell with nothing to configure.

## How the pieces fit together

| Layer | Provides | Where it lives |
|-------|----------|----------------|
| **Container image** | the *tools* (binaries) | the dev image |
| **This repo** | the *configuration* | applied at workspace start via the Coder dotfiles module |
| **Your overlay** | *your* personal tweaks | `~/.config/zsh/local.zsh` (created for you, never tracked) |

Because the tools are baked into the image, `install.sh` only creates symlinks —
no downloads on boot, so a flaky network can't break the shell.

## What you get

**Shell** — zsh with [antidote](https://github.com/mattmc3/antidote) plugins
(autosuggestions, fzf-tab completion, syntax highlighting, and a *you-should-use*
helper), a fast [starship](https://starship.rs) prompt, and sensible
history/completion.

**Modern CLI** — [`mise`](https://mise.jdx.dev) (runtimes + env),
[`eza`](https://eza.rocks) (ls), [`bat`](https://github.com/sharkdp/bat) (cat &
man pages), [`fd`](https://github.com/sharkdp/fd) + [`fzf`](https://github.com/junegunn/fzf)
(find), [`ripgrep`](https://github.com/BurntSushi/ripgrep) (grep),
[`zoxide`](https://github.com/ajeetdsouza/zoxide) (smart `cd`, use `z`),
[`git-delta`](https://github.com/dandavison/delta) (diffs), and
[`lazygit`](https://github.com/jesseduffield/lazygit) (`lg`).

**Git** — modern defaults (rebase pulls, auto-setup-remote, histogram diffs,
`zdiff3` conflicts, rerere) and delta-powered diffs. **No identity is shipped.**

## Runtimes: pin them per project

Don't install language runtimes globally. In each repo, add a `mise.toml`:

```toml
[tools]
node = "22"
python = "3.12"
rust = "stable"
```

`mise` installs and switches to them automatically when you `cd` in.

## Git identity

This repo ships **no** name/email. On Coder, identity comes from your workspace
profile automatically. Anywhere else, set it once in `~/.config/git/local.config`
(a stub is created for you).

## Make it yours

Everything personal goes in `~/.config/zsh/local.zsh` — aliases, exports, or
opt-in tools like [atuin](https://atuin.sh) (`eval "$(atuin init zsh)"`). You get
the baseline *and* your own setup without forking this repo.

## Install by hand

```bash
git clone https://github.com/<org>/dotfiles ~/.dotfiles
~/.dotfiles/install.sh
```

Install whichever tools you want from the list above; every integration is
guarded, so missing tools simply don't activate.
