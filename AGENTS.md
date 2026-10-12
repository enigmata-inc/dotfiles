# dotfiles

The team shell and tool configuration for Coder workspaces (public repo
`enigmata-inc/dotfiles`). `README.md` is the user guide; this file is what you
need before changing anything here.

## How it reaches a workspace

Every `enigmata-inc/coder-templates` template includes the `coder/dotfiles`
module with this repo (branch `main`) as the default URL. On each workspace
start the module clones the repo into `~/.config/coderv2/dotfiles`, or runs
`git pull --ff-only` there when the clone exists, and then runs `install.sh`.
So a merge to `main` reaches every workspace on its next start, with no
review step in between. The tools themselves come from the coder-templates
image, not from here.

`install.sh`:

- symlinks every file under `home/` into `$HOME`, moving anything in the way
  aside to `<file>.bak`;
- deep-merges `claude/settings.json` into `~/.claude/settings.json` with `jq`
  (never a symlink, because Claude Code rewrites that file at runtime);
- creates the untracked stubs `~/.config/zsh/local.zsh`,
  `~/.config/git/local.config` and `~/.config/git/identity.config`, and writes
  `~/.config/git/delta.config` only when `delta` is installed.

We chose not to use `set -e` in `install.sh` because one failed step must not
abort boot for the whole fleet; each step reports its failure and the script
exits non-zero at the end. Revisit if a step ever has to run only after an
earlier one succeeded.

## What a change here touches

- `home/.claude/CLAUDE.md` becomes `~/.claude/CLAUDE.md`, the global Claude
  Code instructions for every agent on every box.
- `home/.zshenv` runs for every zsh, including non-interactive ones, so keep it
  fast and free of output. It sets `ORT_DISABLE_TELEMETRY=1`, which stops
  onnxruntime's telemetry in every shell (#12); keep it while onnxruntime
  ships telemetry on by default.
- The image bakes the antidote plugin bundle from `home/.config/zsh/.zsh_plugins.txt`
  at the commit pinned by `DOTFILES_REF` in coder-templates' `Dockerfile`. A
  plugin added here needs that pin bumped (and an image rebuild) to be in the
  baked bundle.

## Trap: the live clone on a box

`~/.zshrc`, `~/.zshenv`, `~/.gitconfig` and the other linked files are
symlinks into the clone, so editing one edits a tracked file in
`~/.config/coderv2/dotfiles`. The next start's `git pull --ff-only` then meets
local changes, and with this repo's `rebase.autostash` a manual `git pull`
there can stash, pull, and leave conflict markers in `~/.zshenv`, which breaks
every new zsh. Put per-box changes in `~/.config/zsh/local.zsh` or
`~/.config/git/local.config` instead, make repo changes as a PR from a fresh
clone, and do not pull, reset, or stash inside a box's live clone that carries
local edits.

## Repo rules

The `Protect Repo` ruleset (id 17121606) covers every branch. It blocks
creating, updating, deleting, and force-pushing branches; it requires a pull
request with one approving code-owner review, linear history, signed commits,
CodeQL results, code-quality results, and a Copilot review. Only org admins can
bypass it. There is no CI workflow. Check shell changes with
`bash -n install.sh` and `shellcheck install.sh`, and zsh files with
`zsh -n <file>`.

## Naming

An Enigmata repo (Enigmata, Inc., renamed from Probability Drive). We keep new
`pd`, `PD`, and `probabilitydrive` names out because the rename is meant to be
complete.

## Open work

- **The ruleset asks for CodeQL results this repo cannot produce.** CodeQL
  default setup is configured with no languages (nothing here is a CodeQL
  language), so the `code_scanning` rule can never pass and every merge needs
  an org admin's bypass; #10 to #12 merged that way, with no review. The
  `creation` and `update` rules on every branch also mean a non-admin can only
  propose a change from a fork. Done when the ruleset asks only for what this
  repo can satisfy, or the owner records here that admin bypass is the
  intended path. Owner decides (ruleset change).
