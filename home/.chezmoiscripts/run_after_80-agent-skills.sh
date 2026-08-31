#!/bin/sh
set -eu

# Install agent skills into ~/.agents/skills, linked into Claude Code, Codex and Pi.
# Agents are pinned because the default agent list includes project-only
# targets (e.g. PromptScript) that fail global installs on re-runs.
# Runs on every apply so skills stay up to date.
npx -y skills add https://github.com/cursor/plugins --skill unslop -g -a claude-code -a codex -a pi -y
npx -y skills add https://github.com/mattpocock/skills --skill '*' -y -g -a claude-code -a codex -a pi
npx -y skills add https://github.com/obra/superpowers --skill '*' -y -g -a claude-code -a codex -a pi
npx -y skills add https://github.com/homeassistant-ai/skills --skill '*' -y -g -a claude-code -a codex -a pi
