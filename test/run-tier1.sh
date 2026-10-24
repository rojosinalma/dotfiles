#!/bin/sh
# Tier 1: every role/tags combination applies cleanly without any vault access, the conversion of
# pre-split configs (role minimal|server|desktop + work bool) and the tag checks.
# Runs inside the test container; the repo is mounted read-only at /src.
set -u
. /src/test/lib.sh
export DOTFILES_NO_SECRETS=1 DOTFILES_SKIP_ASDF_INSTALL=1 DOTFILES_SKIP_CARBONYL=1

# The container has no sshd. Non-minimal hosts get a fake drop-in so the import-ids cron
# path (gated on sshd reading authorized_keys.github) is exercised; minimal runs without it.
SSHD_DROPIN=/etc/ssh/sshd_config.d/test-github-keys.conf
fake_sshd_reads_github() {
  sudo mkdir -p /etc/ssh/sshd_config.d
  echo 'AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys.github' | sudo tee "$SSHD_DROPIN" >/dev/null
}

has_tag() { case "/$tags/" in */"$1"/*) return 0 ;; esac; return 1; }

data_is() { # data_is <role> <tags>: the rendered config holds exactly these values
  [ "$(chezmoi execute-template '{{ .role }} {{ .tags | join "/" }}')" = "$1 $2" ]
}

# Asserts every rule that follows from role and tags (set by the caller)
assert_role_tags() {
  check "data is role=$role tags=$tags"        data_is "$role" "$tags"
  if has_tag minimal; then
    check "minimal has no .tool-versions"      sh -c '[ ! -e "$HOME/.tool-versions" ]'
    check "minimal has no asdf binary"         sh -c '[ ! -e "$HOME/.local/bin/asdf" ]'
    check "minimal has no bw binary"           sh -c '[ ! -e "$HOME/.local/bin/bw" ]'
    check "minimal has no import-ids"          sh -c '[ ! -e "$HOME/.ssh/import-ids" ]'
    check "minimal has no import-ids cron"     sh -c '! crontab -l 2>/dev/null | grep -q import-ids'
    check "minimal has no git-radar"           sh -c '[ ! -e "$HOME/.git-radar" ]'
    check "minimal: asdf script did not run"   sh -c '! grep -q "^\[asdf\]" /tmp/apply.log'
  else
    check "import-ids cron entry present"      sh -c 'crontab -l | grep -q import-ids'
    check "import-ids script present"          test -x "$HOME/.ssh/import-ids"
    check "git-radar external present"         test -d "$HOME/.git-radar"
  fi
  if has_tag dev; then
    check "dev has nvim config"                test -d "$HOME/.config/nvim"
    check "dev .tool-versions has bun"         grep -q '^bun ' "$HOME/.tool-versions"
    check "dev: no CLI tools in .tool-versions" sh -c '! grep -qE "^(tmux|neovim|fzf|bat|eza|delta|lazygit|lazydocker|yq|pipx|bitwarden) " "$HOME/.tool-versions"'
    check "dev: lazydocker installed"          sh -c 'lazydocker --version'
    check "dev: yq is mikefarah yq"            sh -c 'yq --version | grep -q mikefarah'
    check "dev: pipx installed"                sh -c 'pipx --version'
  else
    check "no dev: no nvim config"             sh -c '[ ! -e "$HOME/.config/nvim" ]'
    has_tag minimal || check "no dev: .tool-versions has no bun" sh -c '! grep -q "^bun " "$HOME/.tool-versions"'
  fi
  if has_tag gui; then
    check "gui has alacritty config"           test -d "$HOME/.config/alacritty"
    check "gui: carbonyl script did not run"   sh -c '! grep -q "^\[carbonyl\]" /tmp/apply.log'
  else
    check "no gui: no alacritty config"        sh -c '[ ! -e "$HOME/.config/alacritty" ]'
    check "server: carbonyl script ran"        grep -q '^\[carbonyl\]' /tmp/apply.log
  fi
  if [ "$role" = work ]; then
    check "work: kubectl in .tool-versions"    grep -q '^kubectl' "$HOME/.tool-versions"
    check "work: kube-ps1 module in .zpreztorc" grep -q "'kube-ps1'" "$HOME/.zpreztorc"
  else
    check "no work: no kube-ps1 module"        sh -c '! grep -q "kube-ps1" "$HOME/.zpreztorc"'
    has_tag minimal || check "no work: no kubectl in .tool-versions" sh -c '! grep -q "^kubectl" "$HOME/.tool-versions"'
  fi
  check "no secret files were created"         sh -c '[ ! -e "$HOME/.zsh_secrets" ] && [ ! -e "$HOME/.aws_env" ]'
  check "ssh key generated"                    test -f "$HOME/.ssh/id_ed25519"
  check "commit.gpgsign unset (no key in the container)" sh -c '[ -z "$(git config --get commit.gpgsign)" ]'
}

fresh() { # fresh: clean home, sshd drop-in matching the tags
  reset_home
  sudo rm -f "$SSHD_DROPIN"
  # reset_home keeps ~/.local/bin; drop what earlier non-minimal runs installed there
  has_tag minimal && rm -f "$HOME/.local/bin/asdf" "$HOME/.local/bin/bw" "$HOME/.local/bin/lazygit" "$HOME/.local/bin/lazydocker" "$HOME/.local/bin/yq"
  has_tag minimal || fake_sshd_reads_github
}

apply_ok() { # apply_ok <chezmoi init args...>: 0 when init --apply succeeds (log in /tmp/apply.log)
  if chezmoi init --apply --source /src "$@" >/tmp/apply.log 2>&1; then
    ok "chezmoi init --apply $*"
  else
    nok "chezmoi init --apply $*"; tail -40 /tmp/apply.log | sed 's/^/       /'
    return 1
  fi
}

run_combo() { # run_combo <role> <tags>
  role="$1" tags="$2"
  echo
  echo "=== role=$role tags=$tags"
  fresh
  apply_ok --promptChoice role="$role" --promptMultichoice tags="$tags" || return
  assert_shell
  assert_role_tags
}

run_combo homelab server/minimal
run_combo homelab server
run_combo homelab server/dev
run_combo work server
run_combo desktop gui/dev

# Configs written before the role/tags split convert on the next init, without prompting
legacy() { # legacy <old role> <old work> <new role> <new tags>
  role="$3" tags="$4"
  echo
  echo "=== legacy role=$1 work=$2 -> role=$role tags=$tags"
  fresh
  mkdir -p "$HOME/.config/chezmoi"
  printf 'data:\n  role: "%s"\n  work: %s\n' "$1" "$2" > "$HOME/.config/chezmoi/chezmoi.yaml"
  apply_ok </dev/null || return
  assert_role_tags
  check "work key is gone"                     sh -c '! grep -q "work:" "$HOME/.config/chezmoi/chezmoi.yaml"'
}
legacy minimal false homelab server/minimal
legacy server  true  work    server
legacy desktop false homelab server/dev   # no desktop session in the container

# Invalid answers stop the init with a reason
echo
echo "=== invalid tags"
for bad in gui/server dev minimal/dev/server bogus/server; do
  reset_home
  if chezmoi init --source /src --promptChoice role=homelab --promptMultichoice tags="$bad" >/tmp/apply.log 2>&1; then
    nok "tags=$bad was accepted"
  else
    check "tags=$bad rejected with a reason"   grep -q -E 'exactly one of server or gui|exclude each other|is not one of' /tmp/apply.log
  fi
done

# Carbonyl for real once: download, sha256, link, libraries, BROWSER in an interactive shell
echo
echo "=== carbonyl (role=homelab tags=server)"
role=homelab tags=server
fresh
if DOTFILES_SKIP_CARBONYL=0 apply_ok --promptChoice role=homelab --promptMultichoice tags=server; then
  check "carbonyl --version is 0.0.3"          sh -c '"$HOME/.local/bin/carbonyl" --version | grep -qx "Carbonyl 0.0.3"'
  check "BROWSER=carbonyl in an interactive zsh" sh -c '[ "$(zsh -ic "echo \$BROWSER" 2>/dev/null)" = carbonyl ]'
  check "BROWSER unset when DISPLAY is set"    sh -c '[ -z "$(DISPLAY=:0 zsh -ic "echo \$BROWSER" 2>/dev/null)" ]'
  check "chezmoi verify"                       chezmoi verify
fi

# The import-ids gate: without the drop-in the cron is skipped with a log line
echo
echo "=== role=homelab tags=server, sshd not reading authorized_keys.github"
reset_home
sudo rm -f "$SSHD_DROPIN"
if apply_ok --promptChoice role=homelab --promptMultichoice tags=server; then
  check "import-ids cron skipped"              sh -c '! crontab -l 2>/dev/null | grep -q import-ids'
  check "skip reason logged"                   grep -q 'sshd does not read' /tmp/apply.log
fi

echo
echo "tier1: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
