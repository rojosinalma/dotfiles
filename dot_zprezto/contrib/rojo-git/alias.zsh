# source "${0:h}/browser_github.sh"

# Custom Aliases
alias gchm='git checkout main;pull'
compdef _git gchm=git-checkout
alias gchp='git checkout production;pull'
compdef _git gchp=git-checkout
alias gchqa='git checkout qa;pull'
compdef _git gchqa=git-checkout
alias gchs='git checkout staging;pull'
compdef _git gchs=git-checkout
alias gchd='git checkout develop;pull'
compdef _git gchd=git-checkout
#alias gh="hub browse"
alias gclone="git clone"
compdef _git gclone=git-cone
alias prm='commit_and_pr'
alias gpro='git prune remote origin'
compdef _git gpr=git-prune
alias grbr='for branch in `git branch -r --merged | grep -v HEAD`; do echo -e `git show --format="%ci %cr %an" $branch | head -n 1` \\t$branch; done | sort -r'

# Git related, but not Git CMDS.
alias rmorig="find . -name '*.orig' -delete"

# Git Aliases
alias g='git'
compdef g=git
alias gst='git status'
compdef _git gst=git-status
alias gd='git diff'
compdef _git gd=git-diff
alias gdc='git diff --cached'
compdef _git gdc=git-diff
alias gdt='git diff-tree --no-commit-id --name-only -r'
compdef _git gdc=git diff-tree --no-commit-id --name-only -r
alias gpull='git pull'
compdef _git gpull=git-pull
alias gup='git pull --rebase'
compdef _git gup=git-fetch
alias gpush='git push'
compdef _git gpush=git-push
alias gd='git diff'
gdv() { git diff -w "$@" | view - }
compdef _git gdv=git-diff
alias gdt='git difftool'
#alias gc='git commit -v'
compdef _git gc=git-commit
alias gc!='git commit -v --amend'
compdef _git gc!=git-commit
alias gcam='git commit -am'
compdef _git gc=git-commit
alias gca!='git commit -v -a --amend'
compdef _git gca!=git-commit
alias gcm='git commit -m'
compdef _git gcm=git-commit
alias gch='git checkout'
compdef _git gch=git-checkout
alias gr='git remote'
compdef _git gr=git-remote
alias grv='git remote -v'
compdef _git grv=git-remote
alias grmv='git remote rename'
compdef _git grmv=git-remote
alias grrm='git remote remove'
compdef _git grrm=git-remote
alias grset='git remote set-url'
compdef _git grset=git-remote
alias grup='git remote update'
compdef _git grset=git-remote
alias grb='git rebase'
compdef _git grb=git-rebase
alias grbi='git rebase -i'
compdef _git grbi=git-rebase
alias grbc='git rebase --continue'
compdef _git grbc=git-rebase
alias grba='git rebase --abort'
compdef _git grba=git-rebase
alias grbs='git rebase --skip'
compdef _git grba=git-rebase
alias gb='git branch'
compdef _git gb=git-branch
alias gba='git branch -a'
compdef _git gba=git-branch
alias gbr='git branch --remote'
alias gcount='git shortlog -sn'
compdef gcount=git
alias gcl='git config --list'
alias gcp='git cherry-pick'
compdef _git gcp=git-cherry-pick
alias glg='git log --stat --max-count=10'
compdef _git glg=git-log
alias glgg='git log --graph --max-count=10'
compdef _git glgg=git-log
alias glgga='git log --graph --decorate --all'
compdef _git glgga=git-log
alias glo='git log --oneline --decorate --color'
compdef _git glo=git-log
alias glog='git log --oneline --decorate --color --graph'
compdef _git glog=git-log
alias glogf='git log --format=fuller'
compdef _git glogf=git-log
alias gs='git status -s'
compdef _git gs=git-status
alias gadd='git add'
compdef _git gadd=git-add
alias gap='git add --patch'
alias gm='git merge'
compdef _git gm=git-merge
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias gclean='git reset --hard && git clean -dfx'
alias gwc='git whatchanged -p --abbrev-commit --pretty=medium'

# Sign and verify commits with GPG
alias gcs='git commit -S'
compdef _git gcs=git-commit
alias gsps='git show --pretty=short --show-signature'
compdef _git gsps=git-show

# Sign and verify tags with GPG
alias gts='git tag -s'
compdef _git gts=git-tag
alias gvt='git verify-tag'
compdef _git gvt=git verify-tag

#remove the gf alias
#alias gf='git ls-files | grep'

alias gpoat='git push origin --all && git push origin --tags'
alias gmt='git mergetool --no-prompt'
compdef _git gm=git-mergetool

alias gg='git gui citool'
alias gga='git gui citool --amend'
alias gk='gitk --all --branches'

alias gsts='git stash show --text'
alias gsta='git stash'
alias gstp='git stash pop'
alias gstd='git stash drop'

# Will cd into the top of the current repository
# or submodule.
alias grt='cd $(git rev-parse --show-toplevel || echo ".")'

# Git and svn mix
alias git-svn-dcommit-push='git svn dcommit && git push github master:svntrunk'
compdef git-svn-dcommit-push=git

alias gsr='git svn rebase'
alias gsd='git svn dcommit'
#
# Will return the current branch name
# Usage example: git pull origin $(current_branch)
#
function current_branch() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo ${ref#refs/heads/}
}

function current_repository() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return
  echo $(git remote -v | cut -d':' -f 2)
}

# these aliases take advantage of the previous function
alias pull='git pull origin $(current_branch)'
compdef pull=git
alias pur='git pull --rebase origin $(current_branch)'
compdef pur=git
alias push='git push origin $(current_branch)'
compdef push=git
alias gpnp='git pull origin $(current_branch) && git push origin $(current_branch)'
compdef gpnp=git
alias hpush='git push heroku $(current_branch):master'
compdef hpush=git
alias fetch='git fetch --tags'
compdef fetch=git

# Depends on `hub` cli tool
function commit_and_pr() {
  gcam $1
  push
  hub pull-request -m $1 --push
}

# Pretty log messages
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}
alias glp="_git_log_prettily"
compdef _git glp=git-log

# Work In Progress (wip)
# These features allow to pause a branch development and switch to another one (wip)
# When you want to go back to work, just unwip it
#
# This function return a warning if the current branch is a wip
function work_in_progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo "WIP!!"
  fi
}
# these alias commit and uncomit wip branches
alias gwip='git add -A; git ls-files --deleted -z | xargs -r0 git rm; git commit -m "--wip--"'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'

# these alias ignore changes to file
alias gignore='git update-index --assume-unchanged'
alias gunignore='git update-index --no-assume-unchanged'
# list temporarily ignored files
alias gignored='git ls-files -v | grep "^[[:lower:]]"'
