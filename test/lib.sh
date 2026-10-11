# Shared assertions for the tiers. Sourced, not executed.
pass=0 fail=0
ok()   { pass=$((pass + 1)); printf '  \033[32mok\033[0m   %s\n' "$*"; }
nok()  { fail=$((fail + 1)); printf '  \033[31mFAIL\033[0m %s\n' "$*"; }
check() { # check <description> <command...>
  desc="$1"; shift
  if "$@" >/tmp/check.out 2>&1; then ok "$desc"; else nok "$desc"; sed 's/^/       /' /tmp/check.out | head -20; fi
}

# Resets the home directory to a clean state between runs (keeps the chezmoi binary).
reset_home() {
  find "$HOME" -mindepth 1 -maxdepth 1 ! -name .local -exec rm -rf {} +
  rm -rf "$HOME/.local/share/chezmoi" "$HOME/.local/state" "$HOME/.config"
  crontab -r 2>/dev/null || true   # the crontab lives outside $HOME
}

# Common asserts after an apply
assert_shell() {
  check "zsh -il -c true exits 0 with empty stderr (no tty)" sh -c 'err=$(zsh -il -c true 2>&1 >/dev/null); [ -z "$err" ] || { echo "$err"; exit 1; }'
  check "zsh -il -c true is silent on a pty"              sh -c 'out=$(TERM=xterm-256color TMUX=test script -qec "zsh -il -c true" /dev/null | tr -d "\r\n"); [ -z "$out" ] || { echo "$out"; exit 1; }'
  check "PROMPT is set in an interactive zsh"       sh -c '[ -n "$(zsh -ic "echo \$PROMPT" 2>/dev/null)" ]'
  check "git user.email = rojo@rojo.dev"            sh -c '[ "$(git config --get user.email)" = rojo@rojo.dev ]'
  check "login shell is zsh (chsh script)"          sh -c '[ "$(getent passwd "$(id -un)" | cut -d: -f7)" = "$(command -v zsh)" ]'
  check "tmux config loads"                         sh -c 'tmux -L test -f "$HOME/.tmux.conf" start-server \; kill-server'
  check "ssh config parses (Include config.rojo absent is fine)" ssh -G -F "$HOME/.ssh/config" localhost
  check "chezmoi verify"                            chezmoi verify
}
