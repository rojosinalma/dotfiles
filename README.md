# dotfiles

My dotfiles for Linux servers and macOS desktops, managed with [chezmoi](https://www.chezmoi.io).
Public, with **no secrets in git**: those come from Bitwarden at install time.

## New host

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rojosinalma/dotfiles/master/bin/bootstrap)"
```

`bin/bootstrap` installs git, chezmoi and the Bitwarden CLI, logs in and unlocks the vault, runs
`chezmoi init --apply` (asks for `role` and `work` the first time) and then `bin/secrets`. Without a
vault on the host:

```sh
DOTFILES_NO_SECRETS=1 CHEZMOI_ARGS="--promptChoice role=server --promptBool work=false" \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/rojosinalma/dotfiles/master/bin/bootstrap)"
```

Afterwards: `chsh -s $(command -v zsh)`.

## Roles and data

Two prompts, stored in `~/.config/chezmoi/chezmoi.yaml` (`data.role`, `data.work`):

| | `server` | `desktop` |
|---|---|---|
| shell, tmux, git, ssh config, prezto modules | yes | yes |
| asdf runtimes (ruby, nodejs, python, golang, rust) | yes | yes |
| asdf CLI tools (neovim, lazygit, bat, eza, fzf, …) | apt only | yes |
| nvim/lazygit/lazydocker/bat/yamllint/alacritty/kitty configs | no | yes |
| Brewfile (macOS) | no | yes |

`work: true` adds the k8s/cloud set: kubectl, k9s, helm, awscli, gcloud, … in `.tool-versions`,
the kube-ps1/kubectl prezto modules, `kc`/`cf` aliases, `kex`, kube-tmux.

Change an answer: `chezmoi init --promptChoice role=desktop --promptBool work=true` then `chezmoi apply`.

## Layout

```
.chezmoiroot              -> home
home/                     the managed tree (chezmoi source state)
  .chezmoi.yaml.tmpl      config template: prompts, data, autoCommit/autoPush off, add.secrets=error
  .chezmoiignore.tmpl     role/os ignores + the secret targets, which chezmoi must never manage
  .chezmoiexternal.toml   git-radar (git), catppuccin/tmux v2.1.3 (archive)
  .chezmoiscripts/        10 packages (apt + gh/chezmoi/bw/asdf/lazygit binaries, import-ids cron)
                          20 gpg key import from Bitwarden (run_once, first apply)
                          30 prezto + tpm clone and plugin install (onchange: .tmux.conf)
                          40 asdf plugins + install (onchange: .tool-versions)
                          50 ssh key generation + upload to GitHub (run_once)
  dot_zsh/contrib/        my prezto modules (loaded via pmodule-dirs, outside the prezto clone)
bin/bootstrap             new-host one-liner (see above)
bin/secrets               Bitwarden -> ~/.zsh_secrets ~/.aws_env ~/.bedrock_env ~/.npmrc ~/.ssh/config.rojo, gh login, gpg key
bin/test [tier1|tier2]    docker test harness
bin/install-hooks         gitleaks pre-commit hook
```

## Secrets

Never in this repo. `bin/secrets` needs an unlocked vault (`export BW_SESSION=$(bw unlock --raw)`)
and reads these items:

| Bitwarden item | kind | becomes |
|---|---|---|
| `dotfiles/zsh_secrets` | secure note | `~/.zsh_secrets` (0600) |
| `dotfiles/aws_env` | secure note | `~/.aws_env` |
| `dotfiles/bedrock_env` | secure note | `~/.bedrock_env` |
| `dotfiles/npmrc` | secure note | `~/.npmrc` |
| `dotfiles/ssh_config_rojo` | secure note | `~/.ssh/config.rojo` (included by `~/.ssh/config`) |
| `dotfiles/gh_token` | login (password) | `gh auth login --with-token`, then the host's ssh key is added to GitHub |
| `dotfiles/gpg-523CE7AD` | note + attachments `secret.asc`, `ownertrust.txt` | `gpg --import` of the signing key |

The item *name* is the lookup key. `alias dotsecrets` runs the script; `zsecrets` edits `~/.zsh_secrets`.

## Day to day

```sh
chezmoi edit --apply ~/.zshrc     # or: zshconfig, zshaliases, tmuxconfig, gitconfig, sshconfig, prezconfig
chezmoi diff && chezmoi apply
chezmoi cd && git commit -am "..." && git push   # nothing auto-commits
```

Scripts re-run when their inputs change (`.tool-versions`, `.tmux.conf`, the package list);
`DOTFILES_SKIP_ASDF_INSTALL=1 chezmoi apply` skips the slow `asdf install`.

## Tests

```sh
bin/test            # tier 1: ubuntu:26.04 container, every role × work, no vault
bin/test tier2      # + BW_SESSION: gpg import, bin/secrets, gh auth (GPG_PASSPHRASE enables the signed-commit check)
```

Tier 1 asserts a clean `zsh -il` (with and without a tty), a prompt, `git config user.signingkey`,
a loading `.tmux.conf`, a parsing `~/.ssh/config` and `chezmoi verify`.
