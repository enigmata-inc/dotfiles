# dotfiles

A modern dotfiles baseline for [Coder](https://coder.com)
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

**Shell**: zsh with [antidote](https://github.com/mattmc3/antidote) plugins
(autosuggestions, fzf-tab completion, syntax highlighting, and a *you-should-use*
helper), a fast [starship](https://starship.rs) prompt, and sensible
history/completion.

**Modern CLI**: [`mise`](https://mise.jdx.dev) (runtimes + env),
[`eza`](https://eza.rocks) (ls), [`bat`](https://github.com/sharkdp/bat) (cat &
man pages), [`fd`](https://github.com/sharkdp/fd) + [`fzf`](https://github.com/junegunn/fzf)
(find), [`ripgrep`](https://github.com/BurntSushi/ripgrep) (grep),
[`zoxide`](https://github.com/ajeetdsouza/zoxide) (smart `cd`, use `z`),
[`git-delta`](https://github.com/dandavison/delta) (diffs), and
[`lazygit`](https://github.com/jesseduffield/lazygit) (`lg`).

**Git**: modern defaults (rebase pulls, auto-setup-remote, histogram diffs,
`zdiff3` conflicts, rerere) and delta-powered diffs. **Identity is derived from
your GitHub account** (see [Git identity](#git-identity)), not hard-coded.

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

On Coder, the agent injects `GIT_AUTHOR_EMAIL`/`GIT_COMMITTER_EMAIL` from your
Coder **profile** email (e.g. `you@probabilitydrive.com`). That address is often
*not* a verified email on your GitHub account, so GitHub and Vercel reject your
commits (*"commit author email is not valid"*) and block builds.

`home/.config/git/sync-identity.sh` fixes this: on workspace start it derives
your identity from your **GitHub** account (via `gh`) and writes it to
`~/.config/git/identity.env` (sourced by `.zshenv` to override the injected env
vars — env beats `git config`, so this is what actually wins in a shell) and
`~/.config/git/identity.config` (a git-config `[include]`). It prefers your
primary *verified* GitHub email and falls back to your privacy-safe
`{id}+{login}@users.noreply.github.com` address.

Override it any time in `~/.config/git/local.config` (included last, so it
wins) — also where you set identity on non-Coder machines. A stub is created
for you.

> **Note:** the shell override covers terminal/CLI git (including `lazygit`).
> Editors that run git with the raw agent environment (e.g. the VS Code Git
> panel) still inherit the Coder env vars. The complete fleet-wide fix is to
> stop injecting `GIT_*_EMAIL` in the Coder **template** (or inject the
> GitHub-derived value there); this repo handles every shell-driven workflow.

## Make it yours

Everything personal goes in `~/.config/zsh/local.zsh`: aliases, exports, or
opt-in tools like [atuin](https://atuin.sh) (`eval "$(atuin init zsh)"`). You get
the baseline *and* your own setup without forking this repo.

## Install by hand

```bash
~/.dotfiles/install.sh
```

Install whichever tools you want from the list above; every integration is
guarded, so missing tools simply don't activate.
