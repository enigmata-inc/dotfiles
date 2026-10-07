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

# onnxruntime 1.29 and later send telemetry (model names and metadata, hardware details, a device id)
# to Microsoft from any process that imports it, unless this is set before the first import; setting
# it later does nothing. We chose to set it for every shell, so test and dev runs that import
# onnxruntime (classifier OCR, the corpus embedder) send nothing. Reopens if onnxruntime drops the
# provider or makes it opt-in.
export ORT_DISABLE_TELEMETRY=1
