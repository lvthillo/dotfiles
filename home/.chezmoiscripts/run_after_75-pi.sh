#!/bin/sh
set -eu

# pi-coding-agent has no Homebrew formula/cask, so unlike the other harnesses
# it can't ride brew bundle. Install it once as a Volta-managed global npm
# package (same package the official pi.dev installer uses), then converge via
# pi's native self-updater on every apply. Runs before 80-agent-skills so the
# `pi` agent target exists for skill links.
if ! command -v pi >/dev/null 2>&1; then
  npm install --global @earendil-works/pi-coding-agent
else
  pi update --all
fi

# Extensions: declared in ~/.pi/agent/settings.json (chezmoi modify script);
# pi install is idempotent and materializes the clone, `pi update --all`
# above upgrades it.
pi install --no-approve git:github.com/samfoy/pi-lsp-extension
