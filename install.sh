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
#     boot for everyone. Each step is self-contained and best-effort, but every
#     failure is reported to stderr and the script exits non-zero if any fail.
#   * Anything in the way (a real file, or a foreign symlink that points outside
#     this repo) is moved aside to <file>.bak before being symlinked; an
#     existing <file>.bak is never clobbered (a timestamped name is used).
#   * Personal overlay stubs are created but never overwritten.
# ─────────────────────────────────────────────────────────────────────────
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$DOTFILES_DIR/home"

FAILURES=0

log()  { printf '  %s\n' "$*"; }
warn() { printf '  %s\n' "$*" >&2; FAILURES=$((FAILURES + 1)); }

# Move an existing path aside to <path>.bak without ever clobbering a prior
# backup: if <path>.bak already exists, a timestamped name is used instead.
# Warns and returns non-zero on failure so callers can skip rather than
# destroy whatever is in the way.
backup() {
  local path="$1" bak="$1.bak"
  if [ -e "$bak" ] || [ -L "$bak" ]; then
    bak="$path.bak.$(date +%s)"
  fi
  if mv "$path" "$bak"; then
    log "backed up $path -> $bak"
  else
    warn "FAILED to back up $path; leaving it in place"
    return 1
  fi
}

# Symlink every file under home/ into $HOME, preserving directory structure.
link_tree() {
  local src dest target
  while IFS= read -r -d '' src; do
    dest="$HOME/${src#"$HOME_SRC"/}"
    mkdir -p "$(dirname "$dest")" || { warn "FAILED to create $(dirname "$dest")"; continue; }
    if [ -L "$dest" ]; then
      target="$(readlink "$dest")"
      [ "$target" = "$src" ] && continue          # already correct
      # A symlink we manage (points back into this repo) is safe to repoint;
      # a foreign symlink (points elsewhere) is backed up, not clobbered.
      case "$target" in
        "$HOME_SRC"/*) ;;
        *) backup "$dest" || continue ;;
      esac
    elif [ -e "$dest" ]; then
      backup "$dest" || continue                  # real file/dir in the way
    fi
    if ln -sfn "$src" "$dest"; then
      log "linked $dest"
    else
      warn "FAILED to link $dest"
    fi
  done < <(find "$HOME_SRC" -type f -print0)
}

# Create an untracked personal file without ever clobbering an existing one.
stub() {
  local path="$1"; shift
  [ -e "$path" ] && return 0
  mkdir -p "$(dirname "$path")" || { warn "FAILED to create $(dirname "$path")"; return 1; }
  if printf '%s\n' "$@" > "$path"; then
    log "created $path"
  else
    warn "FAILED to create $path"
  fi
}

# Assert the fleet-baseline Claude Code settings (claude/settings.json) in
# ~/.claude/settings.json. That file is deliberately NOT symlinked: Claude Code
# rewrites it at runtime (theme, auto-update state, per-box keys), so a symlink
# would either be clobbered or push one box's runtime state onto the whole
# fleet. Instead the baseline keys are deep-merged in with jq, touching nothing
# else and writing only when a key is missing or differs. A corrupt settings
# file is reported and left alone rather than overwritten.
merge_claude_settings() {
  local baseline="$DOTFILES_DIR/claude/settings.json"
  local settings="$HOME/.claude/settings.json" current merged tmp drift
  [ -f "$baseline" ] || { warn "missing $baseline"; return; }
  command -v jq >/dev/null 2>&1 || { warn "jq not found; cannot apply Claude baseline settings"; return; }
  jq -e . "$baseline" >/dev/null 2>&1 || { warn "$baseline is not valid JSON"; return; }
  mkdir -p "$(dirname "$settings")" || { warn "FAILED to create $(dirname "$settings")"; return; }
  if [ -e "$settings" ]; then
    current="$(jq -c . "$settings" 2>/dev/null)" || { warn "$settings is not valid JSON; leaving it alone (fix it, then re-run)"; return; }
  else
    current="{}"
  fi
  merged="$(jq -c --slurpfile b "$baseline" ". * \$b[0]" <<<"$current")" || { warn "FAILED to merge Claude baseline settings"; return; }
  if [ "$merged" != "$current" ]; then
    tmp="$(mktemp "$(dirname "$settings")/.settings.json.XXXXXX")" || { warn "mktemp failed for $settings"; return; }
    if jq . <<<"$merged" > "$tmp" && mv "$tmp" "$settings"; then
      log "applied Claude baseline settings to $settings"
    else
      rm -f "$tmp"; warn "FAILED to write $settings"; return
    fi
  fi
  # Verify: every baseline leaf must read back with the baseline value.
  drift="$(jq -r --slurpfile b "$baseline" \
    "[(\$b[0] | paths(scalars)) as \$p | select(getpath(\$p) != (\$b[0] | getpath(\$p))) | (\$p | join(\".\"))] | join(\", \")" \
    "$settings" 2>/dev/null)" || { warn "FAILED to read back $settings"; return; }
  [ -z "$drift" ] || warn "Claude baseline settings drift after write in $settings: $drift"
}

main() {
  log "Linking dotfiles from $DOTFILES_DIR"
  link_tree
  merge_claude_settings

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

  # Provide a stable file for the Coder template to write your auto-seeded
  # identity into; it fills this from your GitHub login on workspace start.
  # git silently ignores a missing include, so off Coder it just stays empty.
  local identity_cfg="$HOME/.config/git/identity.config"
  mkdir -p "$(dirname "$identity_cfg")" || warn "FAILED to create $(dirname "$identity_cfg")"
  [ -e "$identity_cfg" ] || : > "$identity_cfg" || warn "FAILED to create $identity_cfg"

  # Enable git-delta as the diff pager ONLY when delta is installed, so the
  # tracked .gitconfig stays portable to machines without it.
  local delta_cfg="$HOME/.config/git/delta.config"
  mkdir -p "$(dirname "$delta_cfg")" || warn "FAILED to create $(dirname "$delta_cfg")"
  if command -v delta >/dev/null 2>&1; then
    if printf '%s\n' \
      "[core]" \
      "	pager = delta" \
      "[interactive]" \
      "	diffFilter = delta --color-only" > "$delta_cfg"; then
      log "enabled git-delta pager"
    else
      warn "FAILED to write $delta_cfg"
    fi
  else
    : > "$delta_cfg" || warn "FAILED to create $delta_cfg"   # empty include — harmless
  fi

  if [ "$FAILURES" -gt 0 ]; then
    printf '  %s\n' "Done with $FAILURES failure(s); see messages above." >&2
    exit 1
  fi
  log "Done."
}

main "$@"
