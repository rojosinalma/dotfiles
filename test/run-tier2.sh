#!/bin/sh
# Tier 2: with an unlocked vault (BW_SESSION + ~/.config/Bitwarden CLI mounted at /bwcli):
# the gpg key is imported, bin/secrets writes the secret files, and a signed commit works.
set -u
. /src/test/lib.sh
export DOTFILES_SKIP_ASDF_INSTALL=1 DOTFILES_SKIP_SSH_KEY_UPLOAD=1

reset_home
mkdir -p "$HOME/.config/Bitwarden CLI" && cp /bwcli/data.json "$HOME/.config/Bitwarden CLI/"

echo "=== tier2 role=server work=false (vault unlocked)"
if chezmoi init --apply --source /src --promptChoice role=server --promptBool work=false >/tmp/apply.log 2>&1; then
  ok "chezmoi init --apply"
else
  nok "chezmoi init --apply"; tail -40 /tmp/apply.log | sed 's/^/       /'
fi
grep '^\[gpg\]' /tmp/apply.log | sed 's/^/       /'
assert_shell

check "gpg secret key 523CE7AD imported" gpg --list-secret-keys 523CE7AD

if /src/bin/secrets >/tmp/secrets.log 2>&1; then ok "bin/secrets"; else nok "bin/secrets (missing items?)"; fi
sed 's/^/       /' /tmp/secrets.log
check "~/.zsh_secrets exists"       test -f "$HOME/.zsh_secrets"
check "~/.zsh_secrets is 0600"      sh -c '[ "$(stat -c %a "$HOME/.zsh_secrets")" = 600 ]'
check "~/.ssh/config.rojo exists"   test -f "$HOME/.ssh/config.rojo"
check "gh authenticated"            gh auth status

if gpg --list-secret-keys 523CE7AD >/dev/null 2>&1; then
  if [ -n "${GPG_PASSPHRASE:-}" ]; then
    tmp="$(mktemp -d)" && cd "$tmp" && git init -q .
    check "signed empty commit" sh -c 'printf "%s" "$GPG_PASSPHRASE" | gpg --batch --pinentry-mode loopback --passphrase-fd 0 --sign --output /dev/null /dev/null && git -c gpg.program=gpg commit -q --allow-empty -S -m test'
    cd "$HOME"
  else
    echo "  skip signed-commit assert (GPG_PASSPHRASE not given)"
  fi
else
  echo "  skip signed-commit assert (no key)"
fi

echo
echo "tier2: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
