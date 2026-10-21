#!/bin/sh
# Dev tier: role=homelab tags=server/dev with the real asdf install (compiles ruby/python, builds
# tmux and bat from source), so compiler or plugin breakage shows up before a rollout. Slow
# (10-20 min); run it on a big host. Runs inside the test container; the repo is at /src.
set -u
. /src/test/lib.sh
export DOTFILES_NO_SECRETS=1 DOTFILES_SKIP_CARBONYL=1

echo "=== dev: role=homelab tags=server/dev, real asdf install"
reset_home
if chezmoi init --apply --source /src --promptChoice role=homelab --promptMultichoice tags=server/dev >/tmp/apply.log 2>&1; then
  ok "chezmoi init --apply"
else
  nok "chezmoi init --apply"; grep -E '^\[|chezmoi:|error' /tmp/apply.log | tail -30 | sed 's/^/       /'
fi
check "no 'could not add plugin' in the log"   sh -c '! grep "could not add plugin" /tmp/apply.log'
cd "$HOME" || exit 1
check "every .tool-versions entry is installed" sh -c 'out=$(asdf current 2>&1 | awk "NR > 1 && \$4 != \"true\""); [ -z "$out" ] || { echo "$out"; exit 1; }'
export PATH="$HOME/.asdf/shims:$PATH"
check "asdf tmux runs"                         sh -c 'tmux -V | grep -q "^tmux 3.5a"'
check "asdf bat runs"                          sh -c 'bat --version | grep -q "^bat 0.25.0"'
check "ruby runs"                              ruby -v
check "python runs"                            python -V
check "zoxide comes from apt"                  sh -c '[ "$(command -v zoxide)" = /usr/bin/zoxide ]'
assert_shell

echo
echo "dev: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
