#!/bin/sh
# Tier 1: every role × work combination applies cleanly without any vault access.
# Runs inside the test container; the repo is mounted read-only at /src.
set -u
. /src/test/lib.sh
export DOTFILES_NO_SECRETS=1 DOTFILES_SKIP_ASDF_INSTALL=1

for role in server desktop; do
  for work in false true; do
    echo
    echo "=== role=$role work=$work"
    reset_home
    if chezmoi init --apply --source /src --promptChoice role="$role" --promptBool work="$work" >/tmp/apply.log 2>&1; then
      ok "chezmoi init --apply"
    else
      nok "chezmoi init --apply"; tail -40 /tmp/apply.log | sed 's/^/       /'
      continue
    fi
    assert_shell
    case "$role" in
      server)  check "server has no nvim config"   sh -c '[ ! -e "$HOME/.config/nvim" ]'
               check "server .tool-versions has no desktop tools" sh -c '! grep -q lazygit "$HOME/.tool-versions"' ;;
      desktop) check "desktop has nvim config"     sh -c '[ -d "$HOME/.config/nvim" ]'
               check "desktop .tool-versions has lazygit" grep -q lazygit "$HOME/.tool-versions" ;;
    esac
    case "$work" in
      true)  check "work: kubectl in .tool-versions"       grep -q '^kubectl' "$HOME/.tool-versions"
             check "work: kube-ps1 module in .zpreztorc"   grep -q "'kube-ps1'" "$HOME/.zpreztorc" ;;
      false) check "no-work: no kubectl in .tool-versions" sh -c '! grep -q "^kubectl" "$HOME/.tool-versions"'
             check "no-work: no kube-ps1 module"           sh -c '! grep -q "kube-ps1" "$HOME/.zpreztorc"' ;;
    esac
    check "no secret files were created"      sh -c '[ ! -e "$HOME/.zsh_secrets" ] && [ ! -e "$HOME/.aws_env" ]'
    check "import-ids cron entry present"     sh -c 'crontab -l | grep -q import-ids'
    check "ssh key generated"                 test -f "$HOME/.ssh/id_ed25519"
  done
done

echo
echo "tier1: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
