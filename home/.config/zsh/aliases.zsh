# Shared team aliases. Personal ones belong in ~/.config/zsh/local.zsh.

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git (the rest is muscle memory + `git` itself)
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gco='git checkout'
alias gb='git branch'

# Package managers / runtimes
alias pn='pnpm'
alias m='mise'

# Safer / handier defaults
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'
