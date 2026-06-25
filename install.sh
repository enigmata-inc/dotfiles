#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────
# Dotfiles installer.
#
# Runs non-interactively on workspace start (Coder dotfiles module) or by hand.
# The CLI tools are provided by the Docker image; this script only links
# configuration, so it is fast, offline, and idempotent — safe to re-run and
# safe to run on every boot for the whole fleet.
#
# Design notes:
#   * `set -e` is intentionally NOT used: a single failure must never abort
#     boot for everyone. Each step is self-contained and best-effort.
#   * Real files are backed up once to <file>.bak before being symlinked.
#   * Personal overlay stubs are created but never overwritten.
# ─────────────────────────────────────────────────────────────────────────
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$DOTFILES_DIR/home"

log() { printf '  %s\n' "$*"; }

# Symlink every file under home/ into $HOME, preserving directory structure.
link_tree() {
  local src dest
  while IFS= read -r -d '' src; do
    dest="$HOME/${src#"$HOME_SRC"/}"
    mkdir -p "$(dirname "$dest")"
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      continue                                   # already correct
    fi
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      mv "$dest" "$dest.bak"
      log "backed up $dest -> $dest.bak"
    fi
    ln -sfn "$src" "$dest"
    log "linked $dest"
  done < <(find "$HOME_SRC" -type f -print0)
}

# Create an untracked personal file without ever clobbering an existing one.
stub() {
  local path="$1"; shift
  [ -e "$path" ] && return 0
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" > "$path"
  log "created $path"
}

main() {
  log "Linking dotfiles from $DOTFILES_DIR"
  link_tree

  stub "$HOME/.config/zsh/local.zsh" \
    "# Personal zsh overlay — not tracked by the team dotfiles repo." \
    "# Add your own aliases, exports, and tweaks here. Examples:" \
    "#   alias k=kubectl" \
    "#   command -v atuin >/dev/null && eval \"\$(atuin init zsh)\"   # opt-in shell history"

  stub "$HOME/.config/git/local.config" \
    "# Personal git config — not tracked by the team dotfiles repo." \
    "# On Coder your identity is auto-seeded from your GitHub login into" \
    "# identity.config; set [user] here only to override it or on other machines:" \
    "# [user]" \
    "#     name = Your Name" \
    "#     email = you@example.com"

  # Ensure the auto-seeded identity include always exists so git never errors on
  # a missing include. The Coder template fills this from your GitHub login on
  # workspace start; off Coder it stays an empty (harmless) include.
  local identity_cfg="$HOME/.config/git/identity.config"
  mkdir -p "$(dirname "$identity_cfg")"
  [ -e "$identity_cfg" ] || : > "$identity_cfg"

  # Enable git-delta as the diff pager ONLY when delta is installed, so the
  # tracked .gitconfig stays portable to machines without it.
  local delta_cfg="$HOME/.config/git/delta.config"
  mkdir -p "$(dirname "$delta_cfg")"
  if command -v delta >/dev/null 2>&1; then
    printf '%s\n' \
      "[core]" \
      "	pager = delta" \
      "[interactive]" \
      "	diffFilter = delta --color-only" > "$delta_cfg"
    log "enabled git-delta pager"
  else
    : > "$delta_cfg"                              # empty include — harmless
  fi

  # Activate the secret-leak pre-commit guard (gitleaks) so a stray secret can
  # never be committed to this public repo. Best-effort: needs `pre-commit`, and
  # only does anything inside the git checkout (a no-op for a bare home symlink).
  if command -v pre-commit >/dev/null 2>&1 && [ -d "$DOTFILES_DIR/.git" ]; then
    ( cd "$DOTFILES_DIR" && pre-commit install >/dev/null 2>&1 ) \
      && log "activated gitleaks pre-commit guard" || true
  fi

  log "Done."
}

main "$@"
