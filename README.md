# dotfiles

My dotfiles for Linux servers and macOS desktops, managed with [chezmoi](https://www.chezmoi.io).
Public, with **no secrets in git**: those come from Bitwarden at install time.

## New host

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rojosinalma/dotfiles/master/bin/bootstrap)"
```

`bin/bootstrap` installs git, chezmoi and the Bitwarden CLI, logs in and unlocks the vault, runs
`chezmoi init --apply` (asks for `role` and `tags` the first time) and then `bin/secrets`. Without a
vault on the host (a small box, e.g. a DietPi node):

```sh
DOTFILES_NO_SECRETS=1 CHEZMOI_ARGS="--promptChoice role=homelab --promptMultichoice tags=server/minimal" \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/rojosinalma/dotfiles/master/bin/bootstrap)"
```

The login shell is switched to zsh by chezmoi itself when sudo works without a password; otherwise
the bootstrap ends with the `chsh` line to run.

The host then registers itself (`bin/register-host`): it appends its entry to `hosts.asc` (public
key only), commits `hosts: register <name>` and pushes, so the next push from silver fans out to it
too. The push uses gh (logged in by `bin/secrets`) or an ssh agent; on a host without a vault,
bootstrap from an `ssh -A` session so the forwarded agent can push. `DOTFILES_HOST_ALIAS` sets the
name (default `hostname -s`), `DOTFILES_NO_REGISTER=1` skips it. When no push is possible the commit
is undone and the bootstrap prints the line to run on silver instead:

```sh
~/dev/dotfiles/bin/hosts add <name> --user <user> --role <role> --tags <tags> && cd ~/dev/dotfiles \
  && git commit -qam "hosts: register <name>" && git push
```

The name must be an ssh alias in silver's `~/.ssh/config.rojo` (`Host <name>`, Bitwarden note
`dotfiles/ssh_config_rojo`), or `bin/sync-hosts` cannot reach the host.

## Role and tags

Two prompts, stored in `~/.config/chezmoi/chezmoi.yaml` (`data.role`, `data.tags`).

`role` is what the host is for, exactly one of:

| role | for | adds |
|---|---|---|
| `homelab` | home servers | nothing on top |
| `work` | work machines | the k8s/cloud set: kubectl, k9s, helm, awscli, gcloud, … in `.tool-versions`, the kube-ps1/kubectl prezto modules, `kc`/`cf` aliases, `kex`, kube-tmux |
| `desktop` | a personal workstation | nothing on top yet |

`tags` say how the host is set up: exactly one of `server` / `gui`, plus at most one of `minimal` / `dev`
(neither = the standard set). A tag outside the list, or a broken combination, stops the init with the reason.

| | `minimal` | standard | `dev` |
|---|---|---|---|
| shell, tmux, git, ssh config, prezto modules, CLI tools (neovim, fzf, eza, bat, delta, …) | yes | yes | yes |
| asdf languages (ruby, nodejs, python, golang, rust) + build deps | no | yes | yes |
| bun (asdf), pipx, lazydocker, yq | no | no | yes |
| git-radar in the prompt, `~/.ssh/import-ids` + cron, Bitwarden CLI, lazygit | no | yes | yes |
| ssh key: generated if missing / uploaded to GitHub | yes / no | yes / yes | yes / yes |
| nvim/lazygit/lazydocker/bat/yamllint configs | no | no | yes |

| | `server` | `gui` |
|---|---|---|
| [Carbonyl](https://github.com/fathyb/carbonyl) (Chromium in the terminal) as `BROWSER` when no display is set | yes | no |
| alacritty/kitty configs, Brewfile (macOS) | no | yes |

asdf manages languages only. CLI tools come from the system package manager (apt, Homebrew) on every
OS and CPU; when the distro lacks a tool or ships a different one under its name (Debian's `yq` is the
Python one), it comes from the upstream GitHub release for amd64/arm64. A tool that leaves asdf goes on
the retired list in `run_onchange_before_10-install-packages`, which removes its plugin so the shim stops
shadowing the system binary.

OS and CPU are never tags: templates read `.chezmoi.os` (`linux`, `darwin`), `.chezmoi.arch` (`amd64`,
`arm64`) and `.chezmoi.osRelease`. Carbonyl is pinned (version + zip sha256 in
`run_onchange_after_45-carbonyl`), Linux amd64/arm64 only. Where AppArmor restricts unprivileged user
namespaces (Ubuntu 23.10+) the script loads `/etc/apparmor.d/carbonyl-<user>` so Chromium keeps its
sandbox. Its Chromium (2023) gets no security fixes: use it for login pages, not for browsing.

| host | role | tags |
|---|---|---|
| silver, tiny | `homelab` | `server/dev` |
| turing-1..4 | `homelab` | `server/minimal` |

`~/.gitconfig` turns on commit signing (`commit.gpgsign`, `user.signingkey 523CE7AD`) only when
that secret key is in the host's gpg keyring; after importing it (`bin/secrets`), run `chezmoi apply`
once to re-render the file. The `import-ids` cron is only added where sshd reads
`~/.ssh/authorized_keys.github` (`AuthorizedKeysFile` in `sshd_config` or a `sshd_config.d` drop-in).

Change the answers (multichoice values are `/`-separated; `--prompt` forces the asked-once prompts):

```sh
chezmoi init --prompt --promptChoice role=homelab --promptMultichoice tags=server/dev \
  && chezmoi apply
```

A config from before the role/tags split (`role: minimal|server|desktop`, `work: bool`) converts on the
next `chezmoi init` without asking: `minimal` → `server/minimal`, `server` → `server`, `desktop` → `dev`
plus `gui` or `server` by the presence of a desktop session; `work: true` → role `work`, else `homelab`.

## Layout

```
.chezmoiroot              -> home
home/                     the managed tree (chezmoi source state)
  .chezmoi.yaml.tmpl      config template: prompts, data, autoCommit/autoPush off, add.secrets=error
  .chezmoiignore.tmpl     tag/os ignores + the secret targets, which chezmoi must never manage
  .chezmoiexternal.toml.tmpl  git-radar (git, not for minimal), catppuccin/tmux v2.1.3 (archive)
  .chezmoiscripts/        10 packages (apt/brew + gh/chezmoi/bw/asdf/lazygit/lazydocker/yq binaries, retired asdf plugins, import-ids cron)
                          20 gpg key import from Bitwarden (run_once, first apply)
                          30 prezto + tpm clone and plugin install (onchange: .tmux.conf)
                          40 asdf plugins + install, languages only (onchange: .tool-versions; empty for minimal)
                          45 Carbonyl for server hosts (pinned zip, libraries, AppArmor profile)
                          50 ssh key generation + upload to GitHub (run_once)
                          60 chsh to zsh when it is not the login shell yet (needs passwordless sudo)
  dot_zsh/contrib/        my prezto modules (loaded via pmodule-dirs, outside the prezto clone)
bin/bootstrap             new-host one-liner (see above)
bin/secrets               Bitwarden -> ~/.zsh_secrets ~/.aws_env ~/.bedrock_env ~/.npmrc ~/.ssh/config.rojo, gh login, gpg key
bin/hosts                 registry of the hosts (hosts.asc): list, add, set, remove
bin/test [tier1|dev|tier2]  docker test harness
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

`git push` from the source clone updates every other host registered in `hosts.asc` a few seconds later
(`.githooks/pre-push` → `bin/sync-hosts`: `chezmoi update --init --force` + `chezmoi verify` over ssh, one
line per host; `bin/install-hooks` wires it). A host that was off catches up on its next ssh login:
`.zshrc` compares the clone with origin (at most hourly, 3 s cap) and runs `chezmoi update --force`
when it is behind. `--init` re-renders the config, so a change to the template reaches every host. `bin/sync-hosts [host…]` also runs by hand.

Scripts re-run when their inputs change (`.tool-versions`, `.tmux.conf`, the package list, the Carbonyl pin);
`DOTFILES_SKIP_ASDF_INSTALL=1 chezmoi apply` skips the slow `asdf install`, `DOTFILES_SKIP_CARBONYL=1` the Carbonyl install.

## Tests

```sh
bin/test            # tier 1: ubuntu:26.04 container, role/tags combinations, no vault
bin/test dev        # real asdf install for homelab server/dev (10-20 min; run it on tiny)
bin/test tier2      # + BW_SESSION: gpg import, bin/secrets, gh auth (GPG_PASSPHRASE enables the signed-commit check)
```

Tier 1 (five role/tags combinations, the conversion of old configs, rejected tags, one real Carbonyl install) asserts a clean `zsh -il`
(with and without a tty), a prompt, the git identity (no signing: the container has no key), a loading
`.tmux.conf`, a parsing `~/.ssh/config`, the login shell switched to zsh and `chezmoi verify`. Tier 2
asserts `commit.gpgsign = true` after the key import.
