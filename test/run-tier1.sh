#!/bin/sh
# Tier 1: every role × work combination applies cleanly without any vault access.
# Runs inside the test container; the repo is mounted read-only at /src.
set -u
. /src/test/lib.sh
export DOTFILES_NO_SECRETS=1 DOTFILES_SKIP_ASDF_INSTALL=1

# The container has no sshd. Non-minimal roles get a fake drop-in so the import-ids cron
# path (gated on sshd reading authorized_keys.github) is exercised; minimal runs without it.
SSHD_DROPIN=/etc/ssh/sshd_config.d/test-github-keys.conf
fake_sshd_reads_github() {
  sudo mkdir -p /etc/ssh/sshd_config.d
  echo 'AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys.github' | sudo tee "$SSHD_DROPIN" >/dev/null
}

run_combo() { # run_combo <role> <work>
  role="$1" work="$2"
  echo
  echo "=== role=$role work=$work"
  reset_home
  sudo rm -f "$SSHD_DROPIN"
  [ "$role" = minimal ] || fake_sshd_reads_github
  if chezmoi init --apply --source /src --promptChoice role="$role" --promptBool work="$work" >/tmp/apply.log 2>&1; then
    ok "chezmoi init --apply"
  else
    nok "chezmoi init --apply"; tail -40 /tmp/apply.log | sed 's/^/       /'
    return
  fi
  assert_shell
  case "$role" in
    minimal) check "minimal has no nvim config"       sh -c '[ ! -e "$HOME/.config/nvim" ]'
             check "minimal has no .tool-versions"     sh -c '[ ! -e "$HOME/.tool-versions" ]'
             check "minimal has no asdf binary"        sh -c '[ ! -e "$HOME/.local/bin/asdf" ]'
             check "minimal has no bw binary"          sh -c '[ ! -e "$HOME/.local/bin/bw" ]'
             check "minimal has no import-ids"         sh -c '[ ! -e "$HOME/.ssh/import-ids" ]'
             check "minimal has no import-ids cron"    sh -c '! crontab -l 2>/dev/null | grep -q import-ids'
             check "minimal has no git-radar"          sh -c '[ ! -e "$HOME/.git-radar" ]'
             check "minimal: asdf script did not run"  sh -c '! grep -q "^\[asdf\]" /tmp/apply.log' ;;
    server)  check "server has no nvim config"         sh -c '[ ! -e "$HOME/.config/nvim" ]'
             check "server .tool-versions has no desktop tools" sh -c '! grep -q lazygit "$HOME/.tool-versions"' ;;
    desktop) check "desktop has nvim config"           sh -c '[ -d "$HOME/.config/nvim" ]'
             check "desktop .tool-versions has lazygit" grep -q lazygit "$HOME/.tool-versions" ;;
  esac
  if [ "$role" != minimal ]; then
    check "import-ids cron entry present"     sh -c 'crontab -l | grep -q import-ids'
    check "import-ids script present"         test -x "$HOME/.ssh/import-ids"
    check "git-radar external present"        test -d "$HOME/.git-radar"
  fi
  case "$work" in
    true)  check "work: kubectl in .tool-versions"       grep -q '^kubectl' "$HOME/.tool-versions"
           check "work: kube-ps1 module in .zpreztorc"   grep -q "'kube-ps1'" "$HOME/.zpreztorc" ;;
    false) check "no-work: no kube-ps1 module"           sh -c '! grep -q "kube-ps1" "$HOME/.zpreztorc"'
           [ "$role" = minimal ] || check "no-work: no kubectl in .tool-versions" sh -c '! grep -q "^kubectl" "$HOME/.tool-versions"' ;;
  esac
  check "no secret files were created"      sh -c '[ ! -e "$HOME/.zsh_secrets" ] && [ ! -e "$HOME/.aws_env" ]'
  check "ssh key generated"                 test -f "$HOME/.ssh/id_ed25519"
  check "commit.gpgsign unset (no key in the container)" sh -c '[ -z "$(git config --get commit.gpgsign)" ]'
}

run_combo minimal false
for role in server desktop; do
  for work in false true; do
    run_combo "$role" "$work"
  done
done

# The import-ids gate: without the drop-in the cron is skipped with a log line
echo
echo "=== role=server work=false, sshd not reading authorized_keys.github"
reset_home
sudo rm -f "$SSHD_DROPIN"
if chezmoi init --apply --source /src --promptChoice role=server --promptBool work=false >/tmp/apply.log 2>&1; then
  ok "chezmoi init --apply"
  check "import-ids cron skipped"          sh -c '! crontab -l 2>/dev/null | grep -q import-ids'
  check "skip reason logged"               grep -q 'sshd does not read' /tmp/apply.log
else
  nok "chezmoi init --apply"; tail -40 /tmp/apply.log | sed 's/^/       /'
fi

echo
echo "tier1: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
