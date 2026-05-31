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
