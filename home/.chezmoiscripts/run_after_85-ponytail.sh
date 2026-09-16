#!/bin/sh
set -eu

# Native plugins provide automatic activation; shared skills remain client-neutral.
omp plugin install git:github.com/DietrichGebert/ponytail

claude plugin marketplace add DietrichGebert/ponytail
claude plugin marketplace update ponytail
claude plugin install ponytail@ponytail --scope user
claude plugin update ponytail@ponytail --scope user
plugins=$(claude plugin list --json)
if ! printf '%s\n' "$plugins" | node -e '
  const plugins = JSON.parse(require("node:fs").readFileSync(0, "utf8"));
  process.exit(plugins.some(p => p.id === "ponytail@ponytail" && p.scope === "user" && p.enabled) ? 0 : 1);
'; then
  claude plugin enable ponytail@ponytail --scope user
fi

marketplaces=$(copilot plugin marketplace list --json)
if ! printf '%s\n' "$marketplaces" | node -e '
  const marketplaces = JSON.parse(require("node:fs").readFileSync(0, "utf8"));
  process.exit(marketplaces.some(m => m.name === "ponytail") ? 0 : 1);
'; then
  copilot plugin marketplace add DietrichGebert/ponytail
fi
copilot plugin marketplace update ponytail
copilot plugin install ponytail@ponytail
copilot plugin update ponytail@ponytail
# Copilot prefers the generic root manifest, which omits Ponytail's hooks.
# Select the upstream Copilot manifest again after every install/update.
copilot_plugin="${COPILOT_HOME:-$HOME/.copilot}/installed-plugins/ponytail/ponytail"
cp "$copilot_plugin/.github/plugin/plugin.json" "$copilot_plugin/plugin.json"
copilot plugin enable ponytail@ponytail
