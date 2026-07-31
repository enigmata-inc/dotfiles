<!--
  Global CLAUDE.md, managed by the team dotfiles repo.

  install.sh's link_tree symlinks this to ~/.claude/CLAUDE.md on every box that
  applies these dotfiles. Every Coder template applies them by default on
  workspace start, so this is baseline for the whole fleet; other machines get
  it by running install.sh once against a clone. Edits here propagate on the
  next workspace start or `git pull`.

  This file reaches EVERY workspace and every company and identity on it, and
  this repo is PUBLIC, so it must stay generic and secret-free. Nothing
  project-, product-, or company-specific belongs here: that goes in the
  relevant repo's AGENTS.md.

  Everything here is a preference or a trap that cannot be inferred from the
  code. Anything a repo can answer for itself belongs in that repo's AGENTS.md,
  or nowhere.
-->

# Global directives

## Fail loud, fail closed

The most important rule here. On missing config, unknown state, or an
unavailable dependency, raise or refuse to boot. Never fall back to a constant,
never substitute a degraded default, never warn-and-continue, never swallow an
exception you did not specifically expect. No mock, stub, placeholder, or
fabricated data in a real code path. On error show an explicit error state,
never an empty element pretending all is well.

Validate required env and config once, at load time, in one place, naming what
is missing.

## Verify before "done"

Prove it against the real running system before calling it complete: run the
tests, the build, the lint, the typecheck, and exercise the live app. Report
honest caveats. Never assert success without evidence.

Write tests as you build. For a bug fix, add a regression test and prove it is
not tautological (mutate the code, watch it fail, restore).

Verify claims against source, CLI output, or the web, not memory.

## Root cause

Fix the true root cause in the owning component. No band-aids, no masking, no
papering over with an env var. Nothing is dismissed as "pre-existing."

Use current versions (prefer LTS) and fix deprecations properly. Never pin to a
stale version to dodge a problem. Push back on an approach you think is wrong
rather than implementing it.

## Design

Single source of truth. Never hand-duplicate generated types, shared tokens,
versions, or data another system owns; read them from the owner. When a design
starts to feel complicated, stop and rethink rather than adding a second
mechanism alongside the first.

Validate and narrow payloads at the boundary. Never cast to launder data past
the type system.

## Scope

Default to the scope requested: minimal, surgical changes, with no unrelated
cleanup or upgrades riding along. When asked only to review, review and report;
make no changes. When the task IS an audit or a fix sweep, the reverse holds:
nothing is out of scope, fix every issue and every failing test repo-wide.

Treat projects as greenfield with zero users unless told otherwise. No
back-compat shims, migrations, deprecated APIs, feature toggles, or dead code.

## Security

Enforce authz and data invariants at the server and write layer, on
server-derived identity. A UI-only guard is a gap; an unwired gate is fail-open.
Make external and side-effecting writes idempotent. Never expose raw exception
text or vendor internals; log detail server-side and return an opaque id.

Never commit or transmit secrets. Keep them in gitignored env files or the
secret manager, scrub them from logs, and flag any exposure for rotation.

Require explicit per-action authorization naming the target before any
privileged production or destructive operation (prod DDL, IAM, grants, resource
or env-var deletion, branch-protection edits, DB resets). Never bulk-delete as
one composite action.

## Git

Branch, PR, squash-merge. Never push to main. Gate merges on green CI watched to
completion. Prune merged branches. SSH remotes, never HTTP.

On Coder, git reaches GitHub through `coder gitssh` (wired via
`GIT_SSH_COMMAND`), so use `git@github.com:` remotes and expect no key in
`~/.ssh`. Test connectivity with git itself (`git ls-remote`), never with bare
`ssh -T git@github.com`: plain `ssh` ignores `GIT_SSH_COMMAND` and will falsely
report SSH as broken.

Never add `Co-Authored-By`, an AI co-author, or a "Generated with" trailer to a
commit or PR.

## Voice

Be relentlessly honest. Never overstate, never mark unimplemented work done,
never invent an API, email, or citation. In review be blunt and specific with
file and line evidence, and never invent an issue to have something to say.

No em dashes in copy, UI, or docs, and no spaced-hyphen stand-ins. Write
user-facing copy plainly, with minimal jargon.

## Shell

The interactive shell on our machines is zsh; scripts and CI run bash. Never
validate shell code under the wrong one: zsh has no /dev/tcp, splits words
differently, and globs differently, so a probe can pass in your terminal and
fail in CI, or the reverse. Give every script an explicit bash shebang and test
it under bash. When a command you compose inline needs bash semantics, say
`bash -c`, never assume the login shell.

## This box

A dev box we own, here to serve our work. If you need a tool that is missing,
install it.

It hosts more than one company and identity. Keep them strictly separate: never
let names, credentials, branding, or content from one cross into another.
