scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/radar-base.sh"

cd_to_tmp() {
  tmpfile="/tmp/git-prompt-tests-$(time_now)$1"
  mkdir -p "$tmpfile"
  cd "$tmpfile"
}

rm_tmp() {
  cd $scriptDir
  rm -rf /tmp/git-prompt-tests*
}

unset_colours() {
  export COLOR_REMOTE_AHEAD=""
  export COLOR_REMOTE_BEHIND=""
  export COLOR_REMOTE_DIVERGED=""
  export COLOR_REMOTE_NOT_UPSTREAM=""

  export COLOR_LOCAL_AHEAD=""
  export COLOR_LOCAL_BEHIND=""
  export COLOR_LOCAL_DIVERGED=""

  export COLOR_CHANGES_STAGED=""
  export COLOR_CHANGES_UNSTAGED=""
  export COLOR_CHANGES_CONFLICTED=""
  export COLOR_CHANGES_UNTRACKED=""

  export COLOR_BRANCH=""
  export MASTER_SYMBOL="m"

  export RESET_COLOR_LOCAL=""
  export RESET_COLOR_REMOTE=""
  export RESET_COLOR_CHANGES=""
  export RESET_COLOR_BRANCH=""
}

prepare_test_repo() {
  cd_to_tmp "remote"

  git init --quiet
  touch README
  git add .
  git commit -m "initial commit" --quiet
  origin="$(pwd)"

  cd_to_tmp "new"
  git init --quiet
  git remote add origin $origin
  git fetch origin --quiet
  git checkout master --quiet
  git checkout -b foo --quiet
  git push --quiet -u origin foo >/dev/null
  repo="$(pwd)"

  cd "$origin"
  echo "foo" > foo
  git add .
  git commit -m "remote commit" --quiet
  cd "$repo"
  echo "foo" > foo
  git add .
  git commit -m "local commit" --quiet
  echo "foo" > bar
  git fetch origin --quiet
}

test_all_options_set_config() {
  cd_to_tmp "empty"
  export GIT_RADAR_FORMAT="%{branch}%{local}%{changes}"
  # Don't test remote as in no repo you will get upstream error message
  prepare_zsh_colors
  unset_colours

  prompt="$(render_prompt)"
  assertEquals "$prompt" ""

  export GIT_RADAR_FORMAT="%{remote}"
  # Don't test remote as in no repo you will get upstream error message
  prepare_zsh_colors
  unset_colours

  prompt="$(render_prompt)"
  assertEquals "$prompt" "upstream ⚡"
  prepare_test_repo

  export GIT_RADAR_FORMAT="%{remote}%{branch}%{local}%{changes}"
  prepare_zsh_colors
  unset_colours

  prompt="$(render_prompt)"
  assertEquals "$prompt" "m 1 →foo1↑1A"

  export GIT_RADAR_FORMAT="%{remote}%{branch}%{changes}"
  prepare_zsh_colors
  unset_colours

  prompt="$(render_prompt)"
  assertEquals "$prompt" "m 1 →foo1A"

  export GIT_RADAR_FORMAT="%{branch}%{local}%{changes}"
  prepare_zsh_colors
  unset_colours

  prompt="$(render_prompt)"
  assertEquals "$prompt" "foo1↑1A"

  export GIT_RADAR_FORMAT="%{branch}%{changes}"
  prepare_zsh_colors
  unset_colours

  prompt="$(render_prompt)"
  assertEquals "$prompt" "foo1A"

  export GIT_RADAR_FORMAT="%{branch}"
  prepare_zsh_colors
  unset_colours

  prompt="$(render_prompt)"
  assertEquals "$prompt" "foo"

  rm_tmp
}

#test_reorder_parts() {
#  prepare_test_repo
#
#  export GIT_RADAR_FORMAT="%{branch}%{local}%{changes}%{remote}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "foo1↑1Am 1 →" "$prompt"
#
#  export GIT_RADAR_FORMAT="%{local}%{changes}%{remote}%{branch}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "1↑1Am 1 →foo" "$prompt"
#
#  export GIT_RADAR_FORMAT="%{changes}%{remote}%{branch}%{local}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "1Am 1 →foo1↑" "$prompt"
#
#  rm_tmp
#}
#
#test_prefix_and_suffix_changes() {
#  prepare_test_repo
#
#  export GIT_RADAR_FORMAT="%{changes}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "1A" "$prompt"
#
#  export GIT_RADAR_FORMAT="%{[:changes:]}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "[1A]" "$prompt"
#
#  rm_tmp
#}
#
#test_prefix_and_suffix_local() {
#  prepare_test_repo
#
#  export GIT_RADAR_FORMAT="%{local}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "1↑" "$prompt"
#
#  export GIT_RADAR_FORMAT="%{[:local:]}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "[1↑]" "$prompt"
#
#  rm_tmp
#}
#
#test_prefix_and_suffix_branch() {
#  prepare_test_repo
#
#  export GIT_RADAR_FORMAT="%{branch}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "foo" "$prompt"
#
#  export GIT_RADAR_FORMAT="%{[:branch:]}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "[foo]" "$prompt"
#
#  rm_tmp
#}
#
#test_prefix_and_suffix_remote() {
#  prepare_test_repo
#
#  export GIT_RADAR_FORMAT="%{remote}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "m 1 →" "$prompt"
#
#  export GIT_RADAR_FORMAT="%{[:remote:]}"
#  prepare_zsh_colors
#  unset_colours
#
#  prompt="$(render_prompt)"
#  assertEquals "[m 1 →]" "$prompt"
#
#  rm_tmp
#}

. ./shunit/shunit2
