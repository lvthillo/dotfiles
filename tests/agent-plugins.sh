#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/copilot/installed-plugins/ponytail/ponytail/.github/plugin"
printf '%s\n' native >"$tmp/copilot/installed-plugins/ponytail/ponytail/.github/plugin/plugin.json"

cat >"$tmp/bin/agent" <<'EOF'
#!/bin/sh
set -eu
command=${0##*/}
printf '%s %s\n' "$command" "$*" >>"$LOG"
case "$command $*" in
  'omp plugin list --json'|'omp --profile claude plugin list --json')
    printf '%s\n' '{"npm":[{"name":"@dietrichgebert/ponytail"},{"name":"stray"}]}'
    ;;
  'claude plugin list --json')
    printf '%s\n' '[{"id":"ponytail@ponytail","scope":"user"},{"id":"stray@extra","scope":"user"},{"id":"builtin@claude-plugins-official","scope":"user"},{"id":"cloud@synced","scope":"user"},{"id":"project@extra","scope":"project"}]'
    ;;
  'claude plugin marketplace list --json')
    printf '%s\n' '[{"name":"claude-plugins-official"},{"name":"ponytail"},{"name":"extra"}]'
    ;;
  'copilot plugin list --json')
    printf '%s\n' '[{"name":"ponytail","marketplace":"ponytail"},{"name":"stray","marketplace":"extra"}]'
    ;;
  'copilot plugin marketplace list --json')
    printf '%s\n' '[{"name":"copilot-plugins","isDefault":true},{"name":"ponytail","isDefault":false},{"name":"extra","isDefault":false}]'
    ;;
esac
EOF
chmod +x "$tmp/bin/agent"
ln -s agent "$tmp/bin/omp"
ln -s agent "$tmp/bin/claude"
ln -s agent "$tmp/bin/copilot"

chezmoi execute-template -S "$root/home" -f "$root/home/.chezmoiscripts/run_after_85-agent-plugins.sh.tmpl" -o "$tmp/run.sh"
LOG="$tmp/log" COPILOT_HOME="$tmp/copilot" PATH="$tmp/bin:$PATH" sh "$tmp/run.sh"
log=$(cat "$tmp/log")

assert_logged() {
  case "$log" in
    *"$1"*) ;;
    *) printf 'missing command: %s\n' "$1" >&2; exit 1 ;;
  esac
}

assert_not_logged() {
  case "$log" in
    *"$1"*) printf 'unexpected command: %s\n' "$1" >&2; exit 1 ;;
    *) ;;
  esac
}

assert_logged 'omp plugin uninstall npm:stray'
assert_logged 'omp --profile claude plugin uninstall npm:stray'
assert_logged 'claude plugin uninstall stray@extra --scope user --yes'
assert_logged 'claude plugin marketplace remove extra'
assert_logged 'copilot plugin uninstall stray@extra'
assert_logged 'copilot plugin marketplace remove extra'
assert_not_logged 'uninstall npm:@dietrichgebert/ponytail'
assert_not_logged 'uninstall ponytail@ponytail'
assert_not_logged 'marketplace remove ponytail'
assert_not_logged 'uninstall cloud@synced'
assert_not_logged 'uninstall builtin@claude-plugins-official'
assert_not_logged 'uninstall project@extra'
assert_not_logged 'marketplace remove claude-plugins-official'
assert_not_logged 'marketplace remove copilot-plugins'
cmp "$tmp/copilot/installed-plugins/ponytail/ponytail/.github/plugin/plugin.json" "$tmp/copilot/installed-plugins/ponytail/ponytail/plugin.json"

printf 'agent plugin convergence fixture passed\n'
