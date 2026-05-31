# ~/.zshenv — sourced for every zsh invocation. Keep this minimal and fast.

# XDG base directories (modern tools store config/state/cache here).
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# User-local binaries on PATH.
export PATH="$HOME/.local/bin:$PATH"

# Rust/Cargo env, if present on this machine.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Git identity: load the GitHub-derived identity (sync-identity.sh) so it
# OVERRIDES the Coder-injected profile email. Just sources a cached file — fast.
[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/git/identity.env" ] && \
  . "${XDG_CONFIG_HOME:-$HOME/.config}/git/identity.env"
