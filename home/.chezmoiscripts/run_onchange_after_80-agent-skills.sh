#!/bin/sh
set -eu

# Install agent skills into ~/.agents/skills (symlinked into ~/.claude/skills).
# Editing this list re-runs the script on the next apply.
npx -y skills add https://github.com/cursor/plugins --skill unslop -g
